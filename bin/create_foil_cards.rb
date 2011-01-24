#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'mtg/matcher'
require 'mtg/sql_card'
require 'mtg/db'

m = Matcher.new()

File.new(ARGV[0]).readlines.each do |line|
  matches = m.match(line)
  next unless matches.length > 0
  next unless matches[0][1] >= 10
  h = {}
  matches.each do |match|
    next unless match[1] > 2
    c = Card.find(match[0])
    next if c.name == 'Foil'
    next if h.has_key?(c.name)
    h[c.id] = match[1]
  end
  if h.keys.length == 1
    c = Card.find(h.keys[0])
    Card.find_or_create(
      :name => c.name + " Foil",
      :set_name => c.set_name,
      :casting_cost => c.casting_cost,
      :type => c.type,
      :rarity => c.rarity ).save
  else
    warn h.keys.join("\t")
  end
end
