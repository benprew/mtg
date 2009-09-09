#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sequel'
require 'mtg/sql_db'

set_name = ARGV[0]

include SqlDb

@cards = DB[:cards].inner_join(:card_prices, :card_no => :card_no).select(:name, :price).filter(:set_name => set_name)
@rares = @cards.filter(:rarity => 'Rare').all
@uncommons = @cards.filter(:rarity => 'Uncommon').all

def rare_total_for_set(set_name)
  total = 0

  (1..36).each do |i|
    total += @rares[(rand() * @rares.length()).to_i][:price]
    total += @uncommons[(rand() * @uncommons.length()).to_i][:price]
  end

  return total.to_i
end

foo = 0
prices = []

(1..10000).each do |i|
  box_price = rare_total_for_set(set_name)
  if box_price >= 100
    foo += 1
  end
  prices << box_price
end

puts "Average box price: $" + (prices.inject(0.0) { |sum, el| sum + el } / prices.size).to_s
puts foo / 10000.0
