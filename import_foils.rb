#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'mtg/db'
require 'mtg/card'

File.new(ARGV[0]).readlines.each do |line|
  next if line.match /^#/	
  (card_name, set_name) = line.split(/\|/)
  set_name.chop!
  orig_card = Card.first(:name => card_name)
  

  next if Card.first( :name => card_name + ' Foil', :set_name => set_name )

  warn "Creating foil card #{card_name} Foil : #{set_name}"
  
  foil_card = Card.create(
    :name => card_name + ' Foil',
    :casting_cost => orig_card.casting_cost,
    :rules_text => orig_card.rules_text,
    :pow_tgh => orig_card.pow_tgh,
    :type => orig_card.type,
    :rarity => orig_card.rarity,
    :set_name => set_name
    ).save
end
