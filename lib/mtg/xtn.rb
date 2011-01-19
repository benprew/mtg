require 'rubygems'
require 'dm-core'

class Xtn
  include DataMapper::Resource
  
  property :card_id, Integer, :key => true
  property :date, Date, :key => true
  property :external_item_id, String, :key => true
  property :price, Float
  property :xtn_type_id, String
  property :xtns, Integer, :default => 1
end
