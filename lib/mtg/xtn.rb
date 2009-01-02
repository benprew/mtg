require 'rubygems'
require 'dm-core'

class Xtn
  include DataMapper::Resource
  
  property :card_no, Integer, :key => true
  property :date, Date, :key => true
  property :external_item_id, String, :key => true
  property :price, Float
  property :xtn_type_id, String

end
