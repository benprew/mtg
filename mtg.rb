#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'mtg/dataset'
require 'mtg/sql_db'
require 'mtg/cardset'
require 'mtg/sql_card'
require 'mtg/sql_external_item'
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
  @most_expensive_cards = most_expensive_cards('Scars of Mirrodin')
  @most_expensive_alara_reborn_cards = most_expensive_cards('Alara Reborn')
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
      group( :card_id ).all
    )

    @cards.add_decorator(
      :name,
      lambda { |val, row| %Q(<a href="/card/#{row[:card_id]}">#{val}</a>) }
    )
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
    [ :set_name, :cards_in_set, :avg_rare_price, :rare_volume, :avg_uncommon_price, :uncommon_volume ],
    q(%Q(
      SELECT
        cardsets.name as set_name,
        count(card_id) as cards_in_set,
        sum(case when rarity = 'Rare' then price else 0 end) / 
        sum(case when rarity = 'Rare' then xtns else 0 end) as avg_rare_price,
        sum(case when rarity = 'Rare' then xtns else 0 end) as rare_volume,

        sum(case when rarity = 'Uncommon' then price else 0 end) / 
        sum(case when rarity = 'Uncommon' then xtns else 0 end) as avg_uncommon_price,
        sum(case when rarity = 'Uncommon' then xtns else 0 end) as uncommon_volume

      FROM
        cards INNER JOIN cardsets on (cardsets.id = cards.cardset_id) LEFT OUTER JOIN
        xtns_by_card_day ON (cards.id = xtns_by_card_day.card_id)
      WHERE
        date >= date_sub(curdate(), interval 16 day)
      GROUP BY cardsets.name
      ORDER BY 3 desc)
    )
  )

  @sets.add_decorator(:set_name, set_link_decorator())
  
  haml :set
end

get '/set/:set_name' do
  set_name = params[:set_name]
  @sets = Dataset.new(
    [ :card_id, :name, :set_name, :price ],
    q(%Q(
      SELECT card_id, cards.name, cardsets.name as set_name, sum(price)/sum(xtns) as price
      FROM
        cards INNER JOIN cardsets on (cardsets.id = cards.cardset_id) LEFT OUTER JOIN
        xtns_by_card_day ON cards.id = xtns_by_card_day.card_id
      WHERE
        cardsets.name = ?
        AND date >= date_sub(curdate(), interval 16 day)
      GROUP BY cards.name
      ORDER BY price desc), [ params[:set_name] ])
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
    filter(:end_time >= Date.today << 1).
    filter(:price > 0).
    order(:end_time.desc)
  )
      
  d.add_decorator(
    :external_item_id,
    lambda { |val, row| %Q( <a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#{row[:external_item_id]}">auction</a> <a href="/match_auction/#{row[:external_item_id]}">re-match</a> ) }) # "<-- for emacs highlighting
  return d
end

def most_expensive_cards(set_name = false)
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
    #{ set_name ? " WHERE cardsets.name = ? " : "" }
    ORDER BY price DESC
    LIMIT 20  }, set_name ? [ set_name ] : [])
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
      max(c.name) as name,
      max(cardsets.name) as set_name,
      max(price/xtns) as max,
      min(price/xtns) as min,
      sum(price) / sum(xtns) as avg,
      ifnull(sum(xtns), 0) as volume
    FROM
      xtns_by_card_day x INNER JOIN
      cards c ON (c.id = x.card_id)
      INNER JOIN cardsets on (cardsets.id = c.cardset_id)
    WHERE
      date >= date_sub(curdate(), interval 16 day)
    GROUP BY c.id
    ORDER BY sum(xtns) DESC
    LIMIT 20 })

  d = Dataset.new([ :card_id, :name, :set_name, :max, :min, :avg, :volume ], cards)
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

  def card_link_decorator(val, row)
  end
p
  def set_link_decorator
    lambda { |val, row| %Q(<a href="/set/#{row[:set_name]}">#{val}</a>) }
  end

  def auction_link_decorator
    lambda { |val, row| %Q( <a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#{row[:external_item_id]}">auction</a> ) } # "<-- for emacs highlighting
  end

  def rematch_auction_link_decorator
  end

end
