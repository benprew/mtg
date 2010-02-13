#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'optparse'
require 'sinatra/base'
include Sinatra::Delegator

options = {}

OptionParser.new do |op|
  op.on("-c cardset", "filename containing the cardset (text spoiler)") { |val| @cardset_file = val }
  op.on('-e env')    { |val| set :environment, val.to_sym }
end.parse!

# have to require the db after setting the environment
require 'mtg/sql_card'

cards_built = 0
card = {}

open(@cardset_file) do |f|
  prev_key = ''
  f.each do |line|
    line.chop!
    next unless line.match(/\w/)
    
    (key, val) = line.split(/:\s+/)

    key.strip!
    key.downcase!
    key.gsub!(/[^a-z]/, '_')
    key = key.to_sym
    card[key] = val
    is_full_card = false

    if (prev_key == :rules_text && key != :set_rarity)
      card[prev_key] += line
      next
    end

    prev_key = key

    # cards end on the set_rarity key, so we only really check if that's set
    if key == :set_rarity
      is_full_card = true
      if (card.has_key?(:name) && !card.has_key?(:cardname))
        card[:cardname] = card[:name]
      end
        
      %w(cardname set_rarity cost type rules_text).each do |required_key|
        if !card.has_key?(required_key.to_sym)
          p card
          warn "missing key #{required_key}"
          exit
        end
      end  
    end

    if is_full_card
      warn "Building card #{card[:cardname]}"
      card[:set_rarity].split(/, /).each do |sr|
        arr = sr.split(/\s+/)
        rarity = arr.pop
        if rarity == 'Rare' && arr[-1] == 'Mythic'
          rarity = arr.pop + rarity
        end
        set = arr.join(" ")
        c = Card.find_or_create(:name => card[:cardname], :set_name => set)

        c.update(
          :type => card[:type],
          :casting_cost => card[:cost],
          :rules_text => card[:rules_text],
          :pow_tgh => card[:pow_tgh],
          :rarity => rarity )
        cards_built += 1
      end
      card = {}
    end
  end
      
end

puts "Built #{cards_built} cards"
