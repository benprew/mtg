require 'logger'
require 'mtg/trie_matcher'
require 'mtg/sql_db'

class XtnMatcher < Logger::Application
  include SqlDb

  def initialize
    super('XtnMatcher')
    set_log('/tmp/match_xtns.rb.log', 10, 2048000)
  end

  def run
    no_match = 0
    match = 0
    possible_match = 0

    @log.level = Logger::INFO

    @log.info("Building matcher")
    @matcher = TrieMatcher.new(@log)

    @log.info("Loading external items")
    ext_items = db[:external_items].select(:description, :external_item_id).filter(:has_match_been_attempted => 0)

    count = ext_items.count
    @log.info("Matching #{count} items")
    ext_items.each do |item|
      possible_matches = @matcher.match(item[:description])
      if !possible_matches || possible_matches.length == 0
        @log.debug "no matches for #{item[:description]}"
        no_match += 1
      elsif possible_matches.length == 1
        @log.debug "matching card: #{possible_matches[0]}"
        _match_card(item, possible_matches[0])
        match += 1
      else
        @log.debug "saving #{possible_matches.length} possible matches"
        _save_possible_matches(item[:external_item_id], possible_matches)
        possible_match += 1
      end

      db[:external_items].filter(:external_item_id => item[:external_item_id]).update(:has_match_been_attempted => 1)
    end

    @log.info("Matched: #{match} : #{sprintf '%d%%', (count.zero? ? 0 : ((match + 0.0) / count)) * 100}")
    @log.info("No Match: #{no_match}")
    @log.info("Possible Match: #{possible_match}")
  end

  def _match_card(item, card_id)
    e = db[:external_items].filter(:external_item_id => item[:external_item_id])
    e.update(:card_id => card_id, :cards_in_item => _cards_in_description(item[:description]))
  end

  def _cards_in_description(description)
    m = description.match(/x\s*(\d+)/i)
    n = description.match(/(\d+)\s*x/i)
    if m && m[1].to_i < 100
      return m[1].to_i
    elsif n && n[1].to_i < 100
      return n[1].to_i
    else
      return 1
    end
  end

  def _save_possible_matches(ext_item_id, possible_matches)
    @log.debug "deleting old matches"
    db[:possible_matches].filter(:external_item_id => ext_item_id).delete
    @log.debug "inserting new matches"
    possible_matches.each do |pm|
      db[:possible_matches].insert(:external_item_id => ext_item_id, :card_id => pm, :score => 1)
    end
  end
end

