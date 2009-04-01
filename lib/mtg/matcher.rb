require 'mtg/card'
require 'mtg/keyword'

class Matcher
  include Keyword

  attr_accessor :cards_keywords

  def initialize
    if !@cards_keywords
      warn "building keywords"
      @cards_keywords = {}
      _build_keywords_from_cards()
    end

    @rare_keyword_limit = 5
  end

  def _build_keywords_from_cards()
    Card.all.each do |c|
      c.all_keywords.each do |keyword|
        @cards_keywords[keyword] ||= []
        @cards_keywords[keyword] << c.id
      end
    end
  end

  def _points_for_keyword(keyword)
    @cards_keywords[keyword].length >= @rare_keyword_limit ? 1 : 1.5
  end

  def match(description)
    description_keywords = keywords_from_string(description)

    possible_matches = {}
    description_keywords.each do |keyword|
      if @cards_keywords.has_key?(keyword)
        @cards_keywords[keyword].each do |id|
          possible_matches[id] ||= 0
          possible_matches[id] += _points_for_keyword(keyword)
        end
      end
    end

    possible_mathches = possible_matches.select { |key, val| val > 1 } 

    possible_matches = possible_matches.map do |suggested_match|

      card = Card.get(suggested_match[0])

      # special case for foil cards
      if card.name_keywords.include?('foil') && description_keywords.include?('foil')
        suggested_match[1] += 8
      end

      # if all keywords in the description are contained in the card name
      if (description_keywords & card.name_keywords).length == card.name_keywords.length
        suggested_match[1] += 10
      end
      
      # if all keywords and set name match
      if (description_keywords & card.all_keywords).length == card.all_keywords.length
        suggested_match[1] += 18
      end

      suggested_match
    end

    return possible_matches.sort { |a, b| b[1] <=> a[1] }[0..3]
  end

  def _exact_name_match(description)
    Card.all.each { |c| return c if c.name + " " + c.set_name == description }
    false
  end

end

