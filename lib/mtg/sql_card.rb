require 'rubygems'
require 'sequel'
require 'mtg/sql_db'

include SqlDb
DB = db()
class Card < Sequel::Model
  set_primary_key [ :card_no ] 
  db = db()

  def picture
    '/sets/' + set_name.downcase.gsub(/\s/, '_') + '/' + collector_no.to_s + '.jpeg'
  end

end
