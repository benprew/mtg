#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'mtg/dataset'
require 'mtg/sql_db'
require 'mtg/sql_card'
require 'mtg/sql_external_item'
require 'sass'
require 'haml'
require 'json'

include SqlDb

@@base_chart = '/open-flash-chart.swf'

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

get '/card/:card_no/auctions.json' do
  card_no = params[:card_no]
  puts card_no
  JSON.generate({:data => ExternalItems.filter(:card_no => card_no).select(:end_time, :description, :price, :cards_in_item, :end_time).all })
end

get '/' do
  @most_expensive_cards = most_expensive_cards()
  @most_expensive_alara_reborn_cards = most_expensive_cards('Alara Reborn')
  @highest_volume_cards = highest_volume_cards()

  haml :index
end

get '/updates' do
  haml :updates
end

post '/match_auction' do
  ExternalItem.first( :external_item_id => params[:external_item_id] ).
    update( :card_no => params[:card_no], :cards_in_item => params[:cards_in_item] )
  redirect '/match_auction'
end

get '/match_auction' do
  item = ExternalItem.filter(:card_no => nil).reverse_order(:price).first
  redirect sprintf '/match_auction/%s', item[:external_item_id]
end

get '/chart/card/:card_no' do
  card_no = params[:card_no]
  xtns = db[:xtns_by_card_day].
    select(
      (:SUM.sql_function(:price) / :SUM.sql_function(:xtns)).as(:avg_price),
      :price,
      :xtns,
      :date ).
    filter(:card_no => card_no).
    group_by( :date ).
    order_by( :date ).all

  %Q(
{
  "title":{
    "text":  "Card Price",
    "style": "{font-size: 20px; color:#0000ff; font-family: Verdana; text-align: center;}"
  },
 
  "elements":[
    {
      "type":      "line_dot",
      "alpha":     0.5,
      "colour":    "#9933CC",
      "text":      "Price",
      "font-size": 10,
      "values" :   [#{xtns.map { |x| x[:avg_price].to_i }.join(',')}]
    },
    {
      "type":      "line_dot",
      "alpha":     0.5,
      "colour":    "#0033CC",
      "text":      "Volume",
      "font-size": 10,
      "values" :   [#{xtns.map { |x| x[:xtns].to_i }.join(',')}]
    }

  ],
 
  "x_axis":{
    "stroke":1,
    "tick_height":10,
    "colour":"#d000d0",
    "grid_colour":"#00ff00",
    "labels":{
      "rotate" :"vertical",
      "labels" :[#{xtns.map { |x| sprintf'"%s"', x[:date] }.join(',')} ]
     }
   },
 
  "y_axis":{
    "stroke":      4,
    "tick_length": 3,
    "colour":      "#d000d0",
    "grid_colour": "#00ff00",
    "offset":      0,
    "max":         #{xtns.map{ |x| (x[:avg_price]).to_i }.max},
    "steps": #{xtns.map{ |x| (x[:avg_price]).to_i }.max / 8}
  }
}
)
end

get '/match_auction/:external_item_id' do

  query = db[:possible_matches].
        select( :possible_matches__card_no, :name, :set_name, :cards_in_item, :score ).
        inner_join( :cards, :card_no => :card_no ).
        inner_join( :external_items, :external_item_id => :possible_matches__external_item_id ).
        filter( :external_items__external_item_id => params[:external_item_id]).
        reverse_order( :score )

  @e = db[:external_items].filter( :external_item_id => params[:external_item_id]).first
  @possible_matches = 
    Dataset.new(
      [ :card_no, :name, :set_name, :score, :cards_in_item ],
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
  %input{ :type=>"hidden", :name=>"card_no", :value=> @row[:card_no] }
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
      [ :name, :set_name, :price, :card_no ],
      q(%Q(
        SELECT max(name) as name , MAX(set_name) as set_name, price, card_no
        FROM cards LEFT OUTER JOIN card_prices USING (card_no)
        WHERE name like ?
        GROUP BY card_no
      ), [  "%#{@q}%" ])
    )

    @cards.add_decorator(
      :name,
      lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) }
    )
  end
    
  haml :search
end

get '/card/:card_id' do
  @card = Card.first(:card_no => params[:card_id])

  @avg_price = average_price_for_card(@card)
  @auctions_matched_to_card = auctions_matched_to_card(@card)
  @chart_url = @@base_chart + "?data-file=/chart/card/#{@card.card_no}"
  
  haml :card
end

get '/set' do
  @sets = Dataset.new(
    [ :set_name, :cards_in_set, :avg_rare_price, :rare_volume, :avg_uncommon_price, :uncommon_volume ],
    q(%Q(
      SELECT
        set_name,
        count(card_no) as cards_in_set,
        sum(case when rarity = 'Rare' then price else 0 end) / 
        sum(case when rarity = 'Rare' then xtns else 0 end) as avg_rare_price,
        sum(case when rarity = 'Rare' then xtns else 0 end) as rare_volume,

        sum(case when rarity = 'Uncommon' then price else 0 end) / 
        sum(case when rarity = 'Uncommon' then xtns else 0 end) as avg_uncommon_price,
        sum(case when rarity = 'Uncommon' then xtns else 0 end) as uncommon_volume

      FROM
        cards LEFT OUTER JOIN
        xtns_by_card_day USING (card_no)
      WHERE
        date >= date_sub(curdate(), interval 16 day)
      GROUP BY set_name
      ORDER BY 3 desc)
    )
  )

  @sets.add_decorator(:set_name, set_link_decorator())
  
  haml :set
end

get '/set/:set_name' do
  set_name = params[:set_name]
  @sets = Dataset.new(
    [ :card_no, :name, :set_name, :price ],
    q(%Q(
      SELECT card_no, name, set_name, sum(price)/sum(xtns) as price
      FROM
        cards LEFT OUTER JOIN
        xtns_by_card_day USING (card_no)
      WHERE
        set_name = ?
        AND date >= date_sub(curdate(), interval 16 day)
      GROUP BY name
      ORDER BY price desc), [ params[:set_name] ])
    )

  @sets.add_decorator(
    :name,
    lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) })


  haml :set

end

def auctions_matched_to_card(card)
  d = Dataset.new(
    [ :date, :description, :price, :cards_in_item, :external_item_id, :end_time ],
    db[:external_items].select(:description, :price, :cards_in_item, :external_item_id, :end_time.as(:date)).filter( :card_no => card.card_no ).all
    )
      
  d.add_decorator(
    :external_item_id,
    lambda { |val, row| %Q( <a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#{row[:external_item_id]}">auction</a> <a href="/match_auction/#{row[:external_item_id]}">re-match</a> ) }) # "<-- for emacs highlighting
  return d
end


def average_price_for_card(card)
  rows = 
    db[:xtns_by_card_day].
    select( (:SUM.sql_function(:price) / :SUM.sql_function(:xtns)).as(:avg) ).
    inner_join( :cards, :card_no => :card_no ).
    filter( :cards__card_no => card.card_no ).first

  return rows[0] ? rows[0] : 0
end

def most_expensive_cards(set_name = false)
  cards = q(%Q{
    SELECT
      card_no,
      c.name as name,
      c.set_name,
      price as price
    FROM
      card_prices INNER JOIN
      cards c USING (card_no)
    #{ set_name ? " WHERE set_name = ? " : "" }
    ORDER BY price DESC
    LIMIT 20  }, set_name ? [ set_name ] : [])
  d = Dataset.new([ :card_no, :name, :set_name, :price ], cards)

  d.add_decorator(
    :name,
    lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) })

  d.add_decorator(
    :set_name,
    lambda { |val, row| %Q(<a href="/set/#{val}">#{val}</a>) })

  return d
end

def highest_volume_cards
  cards = q(%Q{
    SELECT
      card_no,
      max(c.name) as name,
      max(c.set_name) as set_name,
      max(price/xtns) as max,
      min(price/xtns) as min,
      sum(price) / sum(xtns) as avg,
      ifnull(sum(xtns), 0) as volume
    FROM
      xtns_by_card_day INNER JOIN
      cards c USING (card_no)
    WHERE
      date >= date_sub(curdate(), interval 16 day)
    GROUP BY c.card_no
    ORDER BY sum(xtns) DESC
    LIMIT 20 })

  d = Dataset.new([ :card_no, :name, :set_name, :max, :min, :avg, :volume ], cards)
  d.add_decorator(
    :name,
    lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) })

  d.add_decorator(:set_name, set_link_decorator())

  return d
end

helpers do
  def render_dataset(title, dataset)
    @dataset = dataset
    @dataset_title = title
    haml :dataset, :layout => false
  end

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

  def set_link_decorator
    lambda { |val, row| %Q(<a href="/set/#{row[:set_name]}">#{val}</a>) }
  end

  def auction_link_decorator
    lambda { |val, row| %Q( <a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#{row[:external_item_id]}">auction</a> ) } # "<-- for emacs highlighting
  end

  def rematch_auction_link_decorator
  end

end
