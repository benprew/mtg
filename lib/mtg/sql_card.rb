require 'rubygems'
require 'sequel'
require 'mtg/sql_db'
require 'mtg/cardset'

class Card < Sequel::Model
  many_to_one :cardset

  def picture
    m = /[^a-z0-9]/;
    '/sets/' + cardset.name.downcase.gsub(m, '') + '/' + name.downcase.gsub(m, '') + '.jpg'
  end
end
