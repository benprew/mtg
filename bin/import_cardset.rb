#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'optparse'
require 'sinatra/base'
include Sinatra::Delegator
require 'mtg/models/card'
require 'mtg/models/cardset'
require 'iconv'

opts = OptionParser.new do |op|
	op.banner = "Usage: import_cardset.rb [options]"
  op.on("-c cardset", "--cardset CARDSET", "filename containing the cardset (text spoiler)") { |val| @cardset_file = val }
  op.on('-e env')    { |val| warn "Do not use -e. Set environment with RACK_ENV"; exit 1}
end

opts.parse!

if !@cardset_file
	puts "Missing option: CARDSET"
	puts opts
	exit
end

cards_built = 0
card = {}

open(@cardset_file) do |f|
  prev_key = ''
  f.each do |line|
    line.chop!
    next unless line.match(/\w/)

    line = Iconv.iconv('ASCII//TRANSLIT', 'UTF-8', line).join

    (key, val) = line.split(/:\s+/, 2)

    key.strip!
    key.downcase!
    key.gsub!(/[^a-z]/, '_')
    key = key.to_sym
    card[key] = val
    is_full_card = false

    if (prev_key == :rules_text && key != :set_rarity)
      card[prev_key] += "\n" + line
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
      warn "Building card: #{card[:cardname]}"
      card[:set_rarity].split(/, /).each do |sr|
        arr = sr.split(/\s+/)
        rarity = arr.pop
        if rarity == 'Rare' && arr[-1] == 'Mythic'
          rarity = arr.pop + rarity
        end
        set = arr.join(" ").upcase.gsub(/\W+/, '_')

        cs = Cardset.find(:cardset_import_id => set)

        unless cs
          warn "No set named #{set}"
          next
        end
        c = Card.find_or_create(:name => card[:cardname], :cardset_id => cs.id)

        c.update(
          :card_type => card[:type],
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
