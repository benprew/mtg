require 'set'
require 'mtg/keyword'
require 'mtg/models/card'

class Hash
  def insert_as_trie(string, id)
    words = string.split(/\s+/)
    Hash.add_trie_entries(self, words, id)
  end

  protected
  def self.add_trie_entries(hsh, words, id)
    return { :id => id } if words.length == 0

    hsh[words[0]] ||= { :ids => []}
    hsh[words[0]][:ids].push(id)
    hsh[words[0]].merge(add_trie_entries(hsh[words[0]], words[1..-1], id))
  end
end

class TrieMatcher

  include Keyword

  def initialize(log)
    @log = log
    _build_cards_trie()
  end

  def _build_cards_trie()
    @valid_keywords = {}
    @cards_trie = {}
    Card.all do |card|
      name_keywords = keywords_from_string(card[:name])
      set_keywords = keywords_from_string(card.cardset.name)
      all_keywords = [ name_keywords, set_keywords ].flatten
  
      all_keywords.each { |k| @valid_keywords[k] = 1 }
  
      @cards_trie.insert_as_trie((name_keywords + set_keywords).join(" "), card[:id])
      @cards_trie.insert_as_trie((set_keywords + name_keywords).join(" "), card[:id])
      if name_keywords[0] == 'foil'
        name_keywords.shift
        @cards_trie.insert_as_trie( (['foil'] + set_keywords + name_keywords).join(" "), card[:id])
      end
    end
  end

  def match(description)
  
    # There are a lot of "extended art" cards on ebay now, and they sell for a
    # lot more then the actual card, so we want to match them to "not a card"
    if description.match(/(extended|altered).*art/i)
      return []
    end

    # FBB apparently means "Foreign/Black-bordered", so I skip them for
    # now, since they don't list very well and I don't want to try and
    # match them yet
    if description.match(/(fbb|foreign|japanese)/i)
      return []
    end
 
    possible_matches = Set.new()
    ct2 = @cards_trie
    keywords = keywords_from_string(description).select { |i| @valid_keywords[i] }
    keywords.each do |keyword|
      prev_matches = ct2
      ct2 = ct2[keyword]
  
      if !ct2
        possible_matches = prev_matches[:ids]
        break
      elsif ct2[:ids].length == 1
        card_id = ''
        possible_matches = ct2[:ids]
        break
      end

  
    end
    possible_matches.to_a[0..2]
  end
end
