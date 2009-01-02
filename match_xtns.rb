#!/usr/bin/env ruby

require 'rubygems'
require 'dm-core'
require 'mtg/external_item'
require 'mtg/matcher'

DataMapper.setup(:default, 'sqlite3:///var/db/mtg')

def _match_card(external_item, card_no)
  warn "matching card: #{card_no}"
  external_item.card_no = card_no
  external_item.save
end


##############

m = Matcher.new()

warn "done building card keywords"

ExternalItem.all(:card_no => nil).each do |i|
  possible_matches = m.match(i.description)

  p possible_matches
  next unless possible_matches.length > 0
  if possible_matches.length == 1
    if possible_matches[0][1] > 10 
      _match_card(i, possible_matches[0][0])
    end
  elsif possible_matches[0][1] - 10 > possible_matches[1][1]
      _match_card(i, possible_matches[0][0])
  end
end


