#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'mtg'

# Note: Usually get checklist from http://www.abugames.com/set240/
# format should be card_name|set_name ex
# Library of Alexandria|Arabian Nights

File.open(ARGV[0]).each do |line|
  next if line.match /^#/
  (card_name, set_name) = line.split(/\|/)
  set_name.chop!

  cardset = Cardset.first(:name => set_name)
  orig_card = Card.first(:name => card_name)

  warn "Creating foil card #{card_name} Foil : #{set_name}"
  foil = Card.find_or_create(:name => card_name + ' Foil', :cardset_id => cardset.id)
  foil.update(
    :name => card_name + ' Foil',
    :casting_cost => orig_card.casting_cost,
    :rules_text => orig_card.rules_text,
    :pow_tgh => orig_card.pow_tgh,
    :card_type => orig_card.card_type,
    :rarity => orig_card.rarity )
end
