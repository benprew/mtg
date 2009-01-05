require 'mtg/card'
require 'mtg/keyword'

class Matcher
  include Keyword

  attr_accessor :cards_keywords

  @@cards_keywords_filename = 'cards_keywords'

  def initialize
    if !@cards_keywords
      warn "thawing keywords"
      _thaw_cards_keywords()
      if !@cards_keywords
        warn "building keywords"
        @cards_keywords = {}
        _build_keywords_from_cards()
        warn "freezing keywords"
        _freeze_cards_keywords()
      end
    end

    @average_num_keywords =
      @cards_keywords.inject(0) { |r, c| r + c.length } / @cards_keywords.length
  end

  def _build_keywords_from_cards()
    Card.all.each do |c|
      c.all_keywords.each do |keyword|
        @cards_keywords[keyword] ||= []
        @cards_keywords[keyword] << c.id
      end
    end
  end

  def _thaw_cards_keywords
    if File.exists?(@@cards_keywords_filename)
      f = File.new(@@cards_keywords_filename, 'r')
      @cards_keywords = Marshal.restore(f.gets(nil))
    end
  end

  def _freeze_cards_keywords
    f = File.new(@@cards_keywords_filename, 'w')
    f.puts(Marshal.dump(@cards_keywords))
    f.close
  end

  def _points_for_keyword(keyword)
    @cards_keywords[keyword].length >= @average_num_keywords ? 1 : 1.5
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

    top_5 = possible_matches.sort { |a, b| b[1] <=> a[1] }[0..4]
    top_5.each do |suggested_match|

      # if all keywords in the description are contained in the card name
      has_all_keywords_in_name = Card.get(suggested_match[0]).name_keywords.inject(true) do |memo, keyword|
        case memo
          when false : false
          when true : description_keywords.include?(keyword) ? true : false
        end
      end

      suggested_match[1] += 8 if has_all_keywords_in_name
      
      if suggested_match[1] == Card.get(suggested_match[0]).all_keywords.length
        suggested_match[1] += 10
      end
    end

    return top_5.sort { |a, b| b[1] <=> a[1] }
  end

  def _exact_name_match(description)
    Card.all.each { |c| return c if c.name + " " + c.set_name == description }
    false
  end

end

