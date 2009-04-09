require 'trie'
require 'mtg/log'
require 'mtg/keyword'
require 'mtg/card'

class TrieMatcher

  include Log
  include Keyword

  def initialize(log)
    @log = log
    _build_cards_trie()
  end

  def _build_cards_trie()
    @valid_keywords = {}
    @cards_trie = Trie.new
    Card.all.each do |card|
      name_keywords = card.name_keywords
      set_keywords = card.set_keywords
  
      card.all_keywords.each { |k| @valid_keywords[k] = 1 }
  
      @cards_trie.insert((name_keywords + set_keywords).join(" "), card.card_no)
      @cards_trie.insert((set_keywords + name_keywords).join(" "), card.card_no)
      if name_keywords[0] == 'foil'
        name_keywords.shift
        @cards_trie.insert( (['foil'] + set_keywords + name_keywords).join(" "), card.card_no)
      end
    end
  end

  # item is a hash with 2 expected keys ['description'] and ['external_item_id']
  def match(item)
  
    # There are a lot of "extended art" cards on ebay now, and they sell for a
    # lot more then the actual card, so we want to match them to "not a card"
    if item['description'].match(/(extended|altered).*art/i)
      return [-1]
    end

    # FBB apparently means "Foreign/Black-bordered", so I skip them for
    # now, since they don't list very well and I don't want to try and
    # match them yet
    if item['description'].match(/(fbb|foreign)/i)
      return [-1]
    end
 
    possible_matches = []
    ct2 = @cards_trie
    keywords = keywords_from_string(item['description']).select { |i| @valid_keywords[i] }
    keywords.each do |keyword|
      prev_matches = ct2
      ct2 = ct2.find_prefix(keyword)
  
      if ct2.size == 1
        card_no = ''
        ct2.each_value { |v| card_no = v }
        possible_matches << card_no
        break
      elsif ct2.size == 0
        if prev_matches.size < 10
          prev_matches.each_value { |v| possible_matches << v }
        end
        break
      end
  
      ct2 = ct2.find_prefix(" ")
    end

    return possible_matches
  end
end
