#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'optparse'
require 'dm-core'
require 'mtg/db'
require 'mtg/card'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: import_cards.rb <spoiler-file>"

  opts.on("-h", "--help", "Show this help message.") { puts opts; exit }

end.parse!

cards_built = 0
card = {}

open(ARGV[0]) do |f|
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
        set = arr.join(" ")
        c = Card.first_or_create(:name => card[:cardname], :set_name => set)

        c.update_attributes(
          :type => card[:type],
          :casting_cost => card[:cost],
          :rules_text => card[:rules_text],
          :pow_tgh => card[:pow_tgh],
          :rarity => rarity )
        c.save
        cards_built += 1
      end
      card = {}
    end
  end
      
end

puts "Built #{cards_built} cards"
