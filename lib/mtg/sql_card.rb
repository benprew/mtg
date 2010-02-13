require 'rubygems'
require 'sequel'
require 'mtg/sql_db'

include SqlDb
DB = db()
class Card < Sequel::Model
  set_primary_key [ :card_no ] 
end
