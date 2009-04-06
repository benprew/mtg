#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'trie'
require 'mtg/db'
require 'mtg/card'
require 'mtg/external_item'
require 'mtg/keyword'
require 'logger'

include Keyword

def q(sql, bind_params = [])
  return repository(:default).adapter.query(sql, bind_params)
end

def _build_trie(log)
  @valid_keywords = {}
  cards_trie = Trie.new
  Card.all.each do |card|
    name_keywords = card.name_keywords
    set_keywords = card.set_keywords

    card.all_keywords.each { |k| @valid_keywords[k] = 1 }

    cards_trie.insert((name_keywords + set_keywords).join(" "), card.card_no)
    cards_trie.insert((set_keywords + name_keywords).join(" "), card.card_no)
    if name_keywords[0] == 'foil'
      name_keywords.shift
      cards_trie.insert( (['foil'] + set_keywords + name_keywords).join(" "), card.card_no)
    end
  end

  return cards_trie
end

log = Logger.new('/tmp/trie_matcher.rb')
log.level = Logger::DEBUG

log.info("Building Trie")
cards_trie = _build_trie(log)

log.info("Loading external items")
ext_items = q("select external_item_id, description from external_items limit 50000")

log.info("Matching items")
ext_items.each do |item|
  keywords = keywords_from_string(item['description'])

#   # There are a lot of "extended art" cards on ebay now, and they sell for a
#   # lot more then the actual card, so we want to match them to "not a card"
#   if i.description.match(/(extended|altered).*art/i)
#     _match_card(i, -1)
#     next
#   end

#   # FBB apparently means "Foreign/Black-bordered", so I skip them for
#   # now, since they don't list very well and I don't want to try and
#   # match them yet
#   if i.description.match(/(fbb|foreign)/i)
#     _match_card(i, -1)
#     next
#   end


  ct2 = cards_trie

  keywords.each do |keyword|
    next unless @valid_keywords[keyword]
    ct2 = ct2.find_prefix(keyword)

    if ct2.size == 1
      card_no = ''
      ct2.each_value { |v| card_no = v }
      puts sprintf "%s|%s", item['external_item_id'], card_no
      break
    end

    if ct2.size == 0
      log.debug("unable to match: #{keywords.join(' ')} : at keyword #{keyword}")
      break
    end

    ct2 = ct2.find_prefix(" ")
  end
end

