require 'rubygems'
require 'dm-core'

class PossibleMatch
  include DataMapper::Resource

  property :external_item_id, String, :key => true
  property :card_id, Integer, :key => true
  property :score, Float, :required => true
end
