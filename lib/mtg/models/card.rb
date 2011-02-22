require 'rubygems'
require 'sequel'
require 'mtg/sql_db'
require 'mtg/models/cardset'
require 'mtg/models/card_price'

class Card < Sequel::Model
  many_to_one :cardset
  one_to_one :card_price

  def picture
    m = /[^a-z0-9]/;
    '/sets/' + cardset.name.downcase.gsub(m, '') + '/' + name.downcase.gsub(m, '') + '.jpg'
  end

  def price
    card_price && card_price.price
  end
end
