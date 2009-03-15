#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'dm-core'
require 'mtg/external_item'
require 'mtg/matcher'
require 'mtg/card'
require 'mtg/possible_match'
require 'mtg/db'

def _match_card(external_item, card_no)
  warn "matching card: #{card_no}"
  external_item.card_no = card_no
  external_item.cards_in_item = _cards_in_item(external_item)
  external_item.save
end

def _cards_in_item(external_item)
  m = external_item.description.match(/(x\s*(\d+)|(\d)+\s*x)/i)
  if m
    return m[2] || m[3]
  else
    return 1
  end
end

def _save_possible_matches(ext_item, possible_matches)
  repository(:default).adapter.execute('DELETE FROM possible_matches WHERE external_item_id = ?', [ext_item.external_item_id])
  possible_matches.each do |pm|
    PossibleMatch.create(
      :external_item_id => ext_item.external_item_id,
      :card_no => pm[0],
      :score => pm[1]
    ).save
  end
end

##############

m = Matcher.new()

warn "done building card keywords"
count = 0

# q('SELECT description, external_item_id FROM external_items e LEFT OUTER JOIN possible_matches pm USING (external_item_id) WHERE e.card_no IS null and pm.card_no IS null GROUP BY external_item_id')
ExternalItem.all(:card_no => nil).each do |i|
  count += 1
  warn "#{count} items #{Time.now()}" if count % 100 == 0

  # There are a lot of "extended art" cards on ebay now, and they sell for a
  # lot more then the actual card, so we want to match them to "not a card"
  if i.description.match(/(extended|altered).*art/i)
    _match_card(i, -1)
    next
  end

  possible_matches = m.match(i.description)
  next unless possible_matches.length > 0

  _save_possible_matches(i, possible_matches)

  if possible_matches[0][1] >= 10
    warn " #{i.description} ##### #{Card.get(possible_matches[0][0]).name}"
    p possible_matches
  end

  if possible_matches.length == 1
    if possible_matches[0][1] >= 10 
      _match_card(i, possible_matches[0][0])
    end
  elsif possible_matches[0][1] - 9 >= possible_matches[1][1]
      _match_card(i, possible_matches[0][0])
  end
end


