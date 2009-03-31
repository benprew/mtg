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

def _build_trie()
  cards_trie = Trie.new
  Card.all.each do |card|
    cards_trie.insert(card.all_keywords.join(" "), card.card_no)
    cards_trie.insert(card.set_keywords.join(" ") + " " + card.name_keywords.join(" "), card.card_no)
  end

  return cards_trie
end

log = Logger.new(STDERR)
log.level = Logger::DEBUG

log.info("Building Trie")
cards_trie = _build_trie()

log.info("Loading external items")
ext_items = q("select external_item_id, description from external_items")

log.info("Matching items")
ext_items.each do |item|
  keyword_string = keywords_from_string(item['description']).join(" ")
  log.debug(keyword_string)
  ct2 = cards_trie.find_prefix(keyword_string)
  if ct2.size == 1
    card_no = ''
    ct2.each_value { |v| card_no = v }
    puts sprintf "%s|%s", item['external_item_id'], card_no
  elsif ct2.size == 0
    log.debug("no cards")
  elsif ct2.size < 5
    keys = ct2.keys.join "|"
    log.debug(keys)
  else
    log.debug(ct2.size)
  end
end

