#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'mtg/keyword'
require 'mtg/db'
require 'mtg/card'

include Keyword

if ARGV[0].match(/^\d+$/)
  p Card.get(ARGV[0]).all_keywords
else
  p keywords_from_string(ARGV[0])
end
