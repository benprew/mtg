#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'mtg/dataset'
require 'mtg/sql_db'
require 'mtg/models/cardset'
require 'mtg/models/card'
require 'mtg/models/external_item'
require 'sass'
require 'haml'
require 'json'

include SqlDb

configure :production do
  error do
    @error = request.env['sinatra.error']

    warn @error

    status 500
    haml "Internal Server Error"
  end
end

get '/style.css' do
  response['Content-Type'] = 'text/css'
  sass :style
end

get '/' do
  @latest_block = mirrodin_block_cards()
  @highest_volume_cards = highest_volume_cards()

  haml :index
end

get '/updates' do
  haml :updates
end

post '/match_auction' do
  ExternalItem.first( :external_item_id => params[:external_item_id] ).
    update( :card_id => params[:card_id], :cards_in_item => params[:cards_in_item] )
  redirect '/match_auction'
end

get '/match_auction' do
  item = ExternalItem.filter(:card_id => nil).reverse_order(:price).first
  redirect sprintf '/match_auction/%s', item[:external_item_id]
end

get '/match_auction/:external_item_id' do

  query = db[:possible_matches].
        select( :possible_matches__card_id, :cards__name, :cardsets__name, :cards_in_item, :score ).
        inner_join( :cards, :id => :card_id ).
        inner_join( :cardsets, :id => :cardset_id ).
        inner_join( :external_items, :external_item_id => :possible_matches__external_item_id ).
        filter( :external_items__external_item_id => params[:external_item_id]).
        reverse_order( :score )

  @e = db[:external_items].filter( :external_item_id => params[:external_item_id]).first
  @possible_matches =
    Dataset.new(
      [ :card_id, :name, :set_name, :score, :cards_in_item ],
      query.all
    )

  @possible_matches.add_decorator(
    :cards_in_item,
    lambda do |val, row|
      @row = row
      haml %Q(
%form{ :action=> "/match_auction",  :method=>'post' }
  %input{ :type=>"text", :name=>"cards_in_item", :size=>3, :value=> @row[:cards_in_item] }
  %input{ :type=>"hidden", :name=>"external_item_id", :value=> "#{params[:external_item_id]}" }
  %input{ :type=>"hidden", :name=>"card_id", :value=> @row[:card_id] }
  %input{ :type=>"submit", :value=>"Match" }
), :layout => :false
    end)
  haml :match_auction
end

get '/search' do
  if params[:q]
    @q = params[:q]
    @q.gsub!(/[^a-zA-Z0-9]+/, ' ')
    @q.strip!

    @cards = Dataset.new(
      [ :card_id, :name, :set_name, :price ],
      db[:cards].
      select( :cards__name, :cardsets__name.as(:set_name), :price, :cards__id.as(:card_id)).
      inner_join( :cardsets, :id => :cardset_id).
      left_outer_join( :card_prices, :card_id => :cards__id ).
      where( :cards__name.ilike "%#{@q.split(/ /).join('%')}%" ).
      group( :cards__id ).all
    )

    @cards.add_decorator( :name, card_link_decorator )
  end

  haml :search
end

get '/card/:card_id' do
  @card = Card.first(:id => params[:card_id])

  @auctions_matched_to_card = auctions_matched_to_card(@card)

  query =
    db[:xtns_by_card_day].
    select(
      (:SUM.sql_function(:price) / :SUM.sql_function(:xtns)).as(:avg_price),
      :price,
      :xtns,
      :date ).
    filter(:card_id => params[:card_id] ).
    filter{|o| o.date > Date.today << 1}.
    group_by( :date ).
    order_by( :date )

  latest_price = db[:card_prices].select(:price).filter(:card_id => params[:card_id]).first

  @card_price = latest_price && latest_price[:price] ? latest_price[:price] : 0

  @card_prices = Dataset.new(
    [ :date, :avg_price ],
    query.all )

  @card_xtns = Dataset.new(
    [ :date, :xtns ],
    query.all )

  haml :card
end

get '/set' do
  @sets = Dataset.new(
    [ :set_name, :cards_in_set, :release_date, :avg_rare_price, :avg_uncommon_price ],
    q(%Q(
      SELECT
        cardsets.name as set_name,
        count(cards.id) as cards_in_set,
        release_date,
        avg(case when rarity = 'Rare' then price else 0 end) as avg_rare_price,
        avg(case when rarity = 'Uncommon' then price else 0 end) as avg_uncommon_price
      FROM
        cards INNER JOIN cardsets on (cardsets.id = cards.cardset_id) LEFT OUTER JOIN
        card_prices ON (cards.id = card_prices.card_id)
      GROUP BY cardsets.name
      ORDER BY 3 desc)
    )
  )

  @sets.add_decorator(:set_name, set_link_decorator())

  haml :set
end

get '/set/:set_name' do
  @set_name = params[:set_name]
  @sets = Dataset.new(
    [ :card_id, :name, :set_name, :price ],
    q(%Q(
      SELECT cards.id as card_id, cards.name, cardsets.name as set_name, price
      FROM
        cards INNER JOIN cardsets on (cardsets.id = cards.cardset_id) LEFT OUTER JOIN
        card_prices ON cards.id = card_prices.card_id
      WHERE
        cardsets.name = ?
      ORDER BY price desc), [ @set_name ])
    )

  @sets.add_decorator(
    :name,
    lambda { |val, row| %Q(<a href="/card/#{row[:card_id]}">#{val}</a>) })


  haml :set

end

def auctions_matched_to_card(card)

  d = Dataset.new(
    [ :date, :description, :price, :cards_in_item, :external_item_id ],
    db[:external_items].
    select(:description, :price, :cards_in_item, :external_item_id, :end_time.as(:date)).
    filter(:card_id => card.id).
    filter('end_time >= ?', Date.today << 1).
    filter('price > 0').
    order(:end_time.desc)
  )

  d.add_decorator(
    :description,
    lambda { |val, row| %Q( <a target="blank" href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#{row[:external_item_id]}">#{row[:description]}</a> ) } )

  if false
    d.add_decorator(
      :external_item_id,
      lambda do |val, row|
        %Q{
          $('##{row[:external_item_id]}').click(function() {
            $.post('/match_auction', {
              external_item_id: #{row[:external_item_id]},
              card_id: 1,
              cards_in_item: 0
            })
          })
        }
    end )
  end

  return d
end

def mirrodin_block_cards(set_name = false)
  cards = q(%Q{
    SELECT
      c.id as card_id,
      c.name as name,
      cardsets.name as set_name,
      price as price
    FROM
      card_prices INNER JOIN
      cards c ON (c.id = card_prices.card_id) INNER JOIN
      cardsets on (c.cardset_id = cardsets.id)
    WHERE
      cardsets.name = 'Mirrodin Besieged'
      OR cardsets.name = 'Scars of Mirrodin'
      OR cardsets.name = 'New Phyrexia'
    ORDER BY price DESC
    LIMIT 20  }, [] )
  d = Dataset.new([ :card_id, :name, :set_name, :price ], cards)

  d.add_decorator(
    :name,
    lambda { |val, row| %Q(<a href="/card/#{row[:card_id]}">#{val}</a>) })

  d.add_decorator(
    :set_name,
    lambda { |val, row| %Q(<a href="/set/#{val}">#{val}</a>) })

  return d
end

def highest_volume_cards
  cards = q(%Q{
    SELECT
      c.id as card_id,
      c.name as name,
      cardsets.name as set_name,
      x.price,
      x.volume
    FROM
      card_prices x INNER JOIN
      cards c ON (c.id = x.card_id)
      INNER JOIN cardsets on (cardsets.id = c.cardset_id)
    ORDER BY x.volume DESC
    LIMIT 20 })

  d = Dataset.new([ :card_id, :name, :set_name, :price, :volume ], cards)
  d.add_decorator(
    :name,
    lambda { |val, row| %Q(<a href="/card/#{row[:card_id]}">#{val}</a>) })

  d.add_decorator(:set_name, set_link_decorator())

  return d
end

helpers do
  def search_box
    haml :search_box, :layout => false
  end

  def q(sql, bind_params = [])
    if bind_params.length > 0
      return db[sql, bind_params].all
    else
      return db[sql].all
    end
  end

  def to_js_table(dataset, options={})
    @dataset = dataset
    @options = options
    haml :dataset, :layout => false
  end

  def simple_format(text)
    text && text.gsub(/\n/, "<br/>")
  end

  def card_link_decorator
    lambda { |val, row| %Q(<a href="/card/#{row[:card_id]}">#{val}</a>) }
  end

  def set_link_decorator
    lambda { |val, row| %Q(<a href="/set/#{row[:set_name]}">#{val}</a>) }
  end

  def auction_link_decorator
    lambda { |val, row| %Q( <a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#{row[:external_item_id]}">auction</a> ) } # "<-- for emacs highlighting
  end

  def rematch_auction_link_decorator
  end

end
