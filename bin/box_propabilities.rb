#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'optparse'
require 'sinatra/base'
require 'sequel'
include Sinatra::Delegator

options = {}

OptionParser.new do |op|
  op.on("-c cardset", "filename containing the cardset (text spoiler)") { |val| @cardset_file = val }
  op.on('-e env')    { |val| set :environment, val.to_sym }
end.parse!

# have to require the db after setting the environment
require 'mtg/sql_db'

set_name = ARGV[0]
TIMES_TO_SIMULTATE_BOX_TOTAL = 10_000
PACKS_PER_BOX = 36
UNCOMMONS_PER_PACK = 3
FOILS_PER_BOX = 2
WHOLESALE_COST_PER_BOX = 80

include SqlDb

@cards = db[:cards].left_outer_join(:card_prices, :card_id => :id ).select(:name, :price).filter(:set_name => set_name).filter(~:name.like('%Foil%'))
@rares = @cards.filter(:rarity => 'Rare').all
@uncommons = @cards.filter(:rarity => 'Uncommon').all
@foils = db[:cards].left_outer_join(:card_prices, :card_id => :id ).select(:name, :price).filter(:set_name => set_name).filter(:name.like('%Foil%')).filter(~:rarity => 'Mythic Rare').all

class Array
  def random_element
    return self[rand self.length]
  end
end

def rare_total_for_set
  total = 0

  (1..FOILS_PER_BOX).each do
    total += @foils.random_element[:price] || 0
  end

  (1..PACKS_PER_BOX).each do |i|
    total += @rares.random_element[:price] || 0
    (1..UNCOMMONS_PER_PACK).each do |i|
      total += @uncommons.random_element[:price]  || 0
    end
  end

  return total
end

boxes_above_cost = 0
prices = []

(1..TIMES_TO_SIMULTATE_BOX_TOTAL).each do |i|
  box_price = rare_total_for_set
  if box_price >= WHOLESALE_COST_PER_BOX
    boxes_above_cost += 1
  end
  prices << box_price
end

printf "Average box price: $%.2f\n", (prices.inject(0.0) { |sum, el| sum + el } / prices.size)
printf "Min box price: $%.2f\n", prices.min
printf "Max box price: $%.2f\n", prices.max
printf "%% chance of making >= $80 on a box: %.2f%%\n", (boxes_above_cost + 0.0) / TIMES_TO_SIMULTATE_BOX_TOTAL * 100
