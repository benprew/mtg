require 'rubygems'
require 'sequel'
require 'mtg/sql_db'
require 'mtg/cardset'

class Card < Sequel::Model
  set_primary_key [ :card_no ] 
  many_to_one :cardset

  def picture
    '/sets/' + cardset.name.downcase.gsub(/\s/, '_') + '/' + collector_no.to_s + '.jpeg'
  end
end
