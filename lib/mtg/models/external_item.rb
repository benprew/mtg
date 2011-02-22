require 'rubygems'
require 'sequel'
require 'mtg/sql_db'

class ExternalItem < Sequel::Model
  set_primary_key [ :external_item_id ] 
end
