#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'mtg/dataset'
require 'mtg/card'
require 'mtg/xtn'
require 'mtg/external_item'
require 'mtg/db'
require 'mtg/builder'

@@base_chart = '/open-flash-chart.swf'

@@builder = Mtg::Builder.new

configure :production do
  error do
    @error = request.env['sinatra.error']
  
    warn @error
  
    status 500
    haml "Internal Server Error"
  end
end

get '/style.css' do
  headers 'Content-Type' => 'text/css'
  sass :style
end

get '/' do
  @most_expensive_cards = most_expensive_cards()
  @most_expensive_conflux_cards = most_expensive_cards('Conflux')
  @highest_volume_cards = highest_volume_cards()
  haml :index
end

post '/match_auction' do
  e = ExternalItem.get(params[:external_item_id])
  e.card_no = params[:card_no]
  e.cards_in_item = params[:cards_in_item]
  e.save

  p e
  warn "done saving external item"

  redirect '/match_auction'
end

get '/match_auction' do
  redirect sprintf '/match_auction/%s', ExternalItem.first(:card_no => nil).external_item_id
end

get '/chart/card/:card_no' do
  card_no = params[:card_no]
  plan = @@builder.query do
      select :avg_price, :xtns, :price, :date
      where :card_no => card_no
      group_by :date
      order_by :date
  end

  (sql, bind_params) = plan.sql_and_bind_params
  
  xtns = q(sql, bind_params)

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
      "values" :   [#{xtns.map { |x| x['avg_price'].to_i }.join(',')}]
    },
    {
      "type":      "line_dot",
      "alpha":     0.5,
      "colour":    "#0033CC",
      "text":      "Volume",
      "font-size": 10,
      "values" :   [#{xtns.map { |x| x['xtns'].to_i }.join(',')}]
    }

  ],
 
  "x_axis":{
    "stroke":1,
    "tick_height":10,
    "colour":"#d000d0",
    "grid_colour":"#00ff00",
    "labels":{
      "rotate" :"vertical",
      "labels" :[#{xtns.map { |x| sprintf'"%s"', x['date'] }.join(',')} ]
     }
   },
 
  "y_axis":{
    "stroke":      4,
    "tick_length": 3,
    "colour":      "#d000d0",
    "grid_colour": "#00ff00",
    "offset":      0,
    "max":         #{xtns.map{ |x| (x['avg_price']).to_i }.max},
    "steps": #{xtns.map{ |x| (x['avg_price']).to_i }.max / 8}
  }
}
)
end

get '/match_auction/:external_item_id' do

  @e = ExternalItem.get(params[:external_item_id])
  @possible_matches = 
    Dataset.new(
      [ :card_no, :name, :set_name, :score, :cards_in_item ],
      q( %Q(
        SELECT possible_matches.card_no, name, set_name, cards_in_item, score
        FROM
          possible_matches INNER JOIN
          cards USING (card_no) INNER JOIN
          external_items USING (external_item_id)
        WHERE
          external_item_id = ?
        ORDER BY
          score desc
      ), [ params[:external_item_id] ]))

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

    @cards = Dataset.new(
      [ :name, :set_name, :casting_cost, :card_no  ],
      Card.all(:name.like => "%#{@q}%")
    )

    @cards.add_decorator(
      :name,
      lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) }
    )
  end
    
  haml :search
end

get '/card/:card_id' do
  @card = Card.get(params[:card_id])

  @avg_price = average_price_for_card(@card)
  @auctions_matched_to_card = auctions_matched_to_card(@card)
  @chart_url = @@base_chart + "?data-file=/chart/card/#{@card.card_no}"
  
  haml :card
end

get '/set/:set_name' do
  set_name = params[:set_name]
  @sets = Dataset.new(
    [ :card_no, :name, :set_name, :price ],
    q(%Q(
      SELECT card_no, name, set_name, price
      FROM
        cards INNER JOIN
        xtns USING (card_no)
      WHERE set_name = ?
      GROUP BY name
      ORDER BY price desc), [ params[:set_name] ])
    )

  @sets.add_decorator(
    :name,
    lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) })


  haml :set

end

def auctions_matched_to_card(card)
  d = make_dataset do
    select :date, :description, :price, :cards_in_item, :external_item_id, :end_time
    where :card_no => card.card_no
  end
      
  d.add_decorator(
    :external_item_id,
    lambda { |val, row| %Q( <a href="http://cgi.ebay.com/ws/eBayISAPI.dll?ViewItem&item=#{row[:external_item_id]}">auction</a> <a href="/match_auction/#{row[:external_item_id]}">re-match</a> ) }) # "<-- for emacs highlighting
  return d
end


def average_price_for_card(card)
  rows = q(%Q{
SELECT sum(price) / sum(xtns) AS avg
FROM xtns INNER JOIN cards USING (card_no)
WHERE card_no = ?}, card.id)
  return rows[0] ? rows[0] : 0
end

def most_expensive_cards(set_name = false)
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
      xtns INNER JOIN
      cards c USING (card_no)
    #{ set_name ? " WHERE set_name = ? " : "" }
    GROUP BY c.card_no
    ORDER BY 6 DESC
    LIMIT 20  }, set_name ? [ set_name ] : [])
  d = Dataset.new([ :card_no, :name, :set_name, :max, :min, :avg, :volume ], cards)

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
      xtns INNER JOIN
      cards c USING (card_no)
    GROUP BY c.card_no
    ORDER BY sum(xtns) DESC
    LIMIT 20 })

  d = Dataset.new([ :card_no, :name, :set_name, :max, :min, :avg, :volume ], cards)
  d.add_decorator(
    :name,
    lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) })

  d.add_decorator(
    :set_name,
    lambda { |val, row| %Q(<a href="/set/#{val}">#{val}</a>) })

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

  def make_dataset(&blk)
    plan = @@builder.query(&blk)

    (sql, bind_params) = plan.sql_and_bind_params

    warn sql

    return Dataset.new(
      plan.selected_fields,
      q(sql, bind_params)
      )
  end

  def q(sql, bind_params = [])
    return repository(:default).adapter.query(sql, bind_params)
  end

end
