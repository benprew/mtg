#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/sinatra/lib'
$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'mtg/dataset'
require 'mtg/card'
require 'mtg/xtn'
require 'mtg/external_item'

DataMapper.setup(:default, 'sqlite3:///var/db/mtg')

error do
  @error = request.env['sinatra.error']

  warn @error

  status 500
  haml "Internal Server Error"
end

get '/style.css' do
  headers 'Content-Type' => 'text/css'
  sass :style
end

get '/' do
  @most_expensive_cards = most_expensive_cards()
  @most_expensive_shards_of_alara_cards = most_expensive_shards_of_alara_cards()
  @highest_volume_cards = highest_volume_cards()
  haml :index
end

post '/match_auction' do
  e = ExternalItem.get(params[:external_item_id])
  e.card_no = params[:card_no]
  e.cards_in_item = params[:cards_in_item]
  e.save

  @e = ExternalItem.first(:card_no => nil)

  haml :match_auction
end

get '/match_auction' do
  @e = ExternalItem.first(:card_no => nil)

  haml :match_auction
end

get '/search' do
  if params[:q]
    @q = params[:q]
    @q.gsub!(/[^a-zA-Z0-9]+/, ' ')

    @cards = Card.all(:name.like => "%#{@q}%")
  end
    
  haml :search
end

get '/card/:card_id' do
  @card = Card.get(params[:card_id])

  @avg_price = average_price_for_card(@card)
  
  haml :card
end

def average_price_for_card(card)
  rows = repository(:default).adapter.query('select avg(price) as avg from xtns inner join cards using (card_no) where card_no = ?', card.id)
  return rows[0] ? rows[0] : 0
end

def most_expensive_cards
  cards = repository(:default).adapter.query('select card_no, max(c.name) as name, max(c.set_name) as set_name, max(price/xtns) as max, min(price/xtns) as min, avg(price) as avg, ifnull(sum(xtns), 0) as volume from xtns inner join cards c using (card_no) group by c.card_no order by max(price/xtns) desc limit 20')
  d = Dataset.new([ :name, :set_name, :max, :min, :avg, :volume ], cards)
  d.add_decorator(:name,
                  lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) })
  return d
end

def highest_volume_cards
  cards = repository(:default).adapter.query('select card_no, max(c.name) as name, max(c.set_name) as set_name, max(price/xtns) as max, min(price/xtns) as min, avg(price) as avg, ifnull(sum(xtns), 0) as volume from xtns inner join cards c using (card_no) group by c.card_no order by sum(xtns) desc limit 20')
  d = Dataset.new([ :name, :set_name, :max, :min, :avg, :volume ], cards)
  d.add_decorator(:name,
                  lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) })
  return d
end

def most_expensive_shards_of_alara_cards
  cards = repository(:default).adapter.query(%q{select card_no, max(c.name) as name, max(c.set_name) as set_name, max(price/xtns) as max, min(price/xtns) as min, avg(price) as avg, ifnull(sum(xtns), 0) as volume from xtns inner join cards c using (card_no) where set_name = 'Shards of Alara' group by c.card_no order by max(price/xtns) desc limit 20})
  d = Dataset.new([ :name, :set_name, :max, :min, :avg, :volume ], cards)
  d.add_decorator(:name,
                  lambda { |val, row| %Q(<a href="/card/#{row[:card_no]}">#{val}</a>) })
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

end
