#!/usr/bin/ruby

require 'rubygems'
require 'hpricot'

doc = open(ARGV[0]) { |f| Hpricot(f) }

doc.search("div.visualspoiler").search("img") do |img|
  puts img.get_attribute :alt
end
