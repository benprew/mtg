require 'rubygems'
require 'sequel'
require 'mtg/sql_db'

include SqlDb
class ExternalItem < Sequel::Model
  db = db()
  set_primary_key [ :external_item_id ] 
end
