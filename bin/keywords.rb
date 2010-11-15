#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'mtg'
require 'mtg/keyword'
require 'mtg/sql_card'

include Keyword

if ARGV[0].match(/^\d+$/)
  card = Card.first(:card_no => ARGV[0])
  p [ keywords_from_string(card.name), keywords_from_string(card.cardset.name) ].flatten
else
  p keywords_from_string(ARGV[0])
end
