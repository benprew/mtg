#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/sinatra/lib'
$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'mtg/dataset'
require 'mtg/card'
require 'mtg/xtn'

DataMapper.setup(:default, 'sqlite3:///var/db/mtg')

get '/' do
  @top_10_cards = top_10_cards()
  haml :index
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

def top_10_cards
  cards = repository(:default).adapter.query('select c.name as name, max(price/xtns) as max, min(price/xtns) as min, sum(price) / sum(xtns) as avg, count(*) as volume from xtns inner join cards c using (card_no) group by c.name order by 2 desc limit 10')
  Dataset.new(%w(Name Max Min Avg Volume), cards)
end

helpers do
  def render_dataset(dataset)
    @dataset = dataset
    haml :dataset, :layout => false
  end

  def search_box
    haml :search_box, :layout => false
  end

end
