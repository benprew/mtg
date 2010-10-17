require 'rubygems'
require 'dm-core'

class ExternalItem
  include DataMapper::Resource

  property :external_item_id, String, :key => true
  property :description, String, :length => 512
  property :end_time, DateTime
  property :auction_price, Float
  property :buy_it_now_price, Float
  property :card_no, Integer
  property :last_updated, DateTime, :required => true
  property :cards_in_item, Integer, :required => true, :default => 1
  property :price, Float
  property :has_been_finalized, Boolean, :default => false
  property :has_match_been_attempted, Boolean, :default => false
end
