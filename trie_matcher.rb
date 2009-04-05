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
    name_keywords = card.name_keywords
    set_keywords = card.set_keywords

    cards_trie.insert((name_keywords + set_keywords).join(" "), card.card_no)
    cards_trie.insert((set_keywords + name_keywords).join(" "), card.card_no)
    if name_keywords[-1] == 'foil'
      name_keywords.pop
      cards_trie.insert( (['foil'] + name_keywords).join(" "), card.card_no)
      cards_trie.insert( (['foil'] + set_keywords + name_keywords).join(" "), card.card_no)
    end
  end

  return cards_trie
end

log = Logger.new('/tmp/trie_matcher.rb')
log.level = Logger::DEBUG

log.info("Building Trie")
cards_trie = _build_trie()

log.info("Loading external items")
ext_items = q("select external_item_id, description from external_items limit 50000")

log.info("Matching items")
ext_items.each do |item|
  keywords = keywords_from_string(item['description'])
  ct2 = cards_trie

  # strip off any bogus leading keywords
  while keywords.length > 0 && ct2.find_prefix(keywords[0]).size == 0
    keywords.shift
  end

  keywords.each do |keyword|
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

