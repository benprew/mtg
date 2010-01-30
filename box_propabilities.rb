#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sequel'
require 'mtg/sql_db'

set_name = ARGV[0]

include SqlDb

@cards = DB[:cards].left_outer_join(:card_prices, :card_no => :card_no).select(:name, :price).filter(:set_name => set_name).filter(~:name.like('%Foil%'))
@rares = @cards.filter(:rarity => 'Rare').all
@uncommons = @cards.filter(:rarity => 'Uncommon').all
@foils = DB[:cards].left_outer_join(:card_prices, :card_no => :card_no).select(:name, :price).filter(:set_name => set_name).filter(:name.like('%Foil%')).filter(~:rarity => 'Mythic Rare').all

def rare_total_for_set(set_name)
  total = 0

  total += @foils[(rand() * @foils.length()).to_i][:price] || 0
  total += @foils[(rand() * @foils.length()).to_i][:price] || 0

  (1..36).each do |i|
    total += @rares[(rand() * @rares.length()).to_i][:price] || 0
    (1..3).each do |i|
      total += @uncommons[(rand() * @uncommons.length()).to_i][:price]  || 0
    end
  end

  return total.to_i
end


foo = 0
prices = []

(1..10000).each do |i|
  box_price = rare_total_for_set(set_name)
  if box_price >= 80
    foo += 1
  end
  prices << box_price
end

puts "Average box price: $" + (prices.inject(0.0) { |sum, el| sum + el } / prices.size).to_s
puts "Min box price: $" + prices.min.to_s
puts "Max box price: $" + prices.max.to_s
puts "% chance of making >= $80 on a box: " + (foo / 10000.0).to_s
