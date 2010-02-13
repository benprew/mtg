#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

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

File.new(@cardset_file).readlines.each do |line|
  next if line.match /^#/	
  (card_name, set_name) = line.split(/\|/)
  set_name.chop!
  
  orig_card = Card.first(:name => card_name)

  warn "Creating foil card #{card_name} Foil : #{set_name}"
  foil = Card.find_or_create(:name => card_name + ' Foil', :set_name => set_name )
  foil.update(
    :name => card_name + ' Foil',
    :casting_cost => orig_card.casting_cost,
    :rules_text => orig_card.rules_text,
    :pow_tgh => orig_card.pow_tgh,
    :type => orig_card[:type],
    :rarity => orig_card.rarity,
    :set_name => set_name
    )
end
