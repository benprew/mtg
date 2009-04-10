#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'trie'
require 'mtg/db'
require 'logger'
require 'mtg/external_item'
require 'mtg/possible_match'
require 'mtg/trie_matcher'

class XtnMatcher < Logger::Application

  def initialize
    super('XtnMatcher')
    set_log('/tmp/match_xtns.rb.log', 10, 2048000)
  end

  def q(sql, bind_params = [])
    return repository(:default).adapter.query(sql, bind_params)
  end

  def run
    no_match = 0
    match = 0
    possible_match = 0

   @log.level = Logger::INFO
    @log.info("Building matcher")
    @matcher = TrieMatcher.new(@log)

    @log.info("Loading external items")
    ext_items = q('SELECT description, external_item_id FROM external_items e LEFT OUTER JOIN possible_matches pm USING (external_item_id) WHERE e.card_no IS null and pm.card_no IS null GROUP BY external_item_id')
    
    @log.info("Matching #{ext_items.length} items")
    ext_items.each do |item|
      possible_matches = @matcher.match(item)
      if !possible_matches || possible_matches.length == 0
        @log.debug "no matches for #{item['description']}"
        no_match += 1
      elsif possible_matches.length == 1
        @log.debug "matching card: #{possible_matches[0]}"
        _match_card(item, possible_matches[0])
        match += 1
      else
        @log.debug "saving #{possible_matches.length} possible matches"
        _save_possible_matches(item['external_item_id'], possible_matches)
        possible_match += 1
      end
    end

    @log.info("Matched: #{match} : #{sprintf '%d%%', ((match + 0.0) / ext_items.length) * 100}")
    @log.info("No Match: #{no_match}")
    @log.info("Possible Match: #{possible_match}")
  end

  def _match_card(item, card_no)
    e = ExternalItem.get(item['external_item_id'])
    e.card_no = card_no
    e.cards_in_item = _cards_in_description(item['description'])
    e.save
  end

  def _cards_in_description(description)
    m = description.match(/(x\s*(\d+)|(\d)+\s*x)/i)
    if m
      return m[2] || m[3]
    else
      return 1
    end
  end

  def _save_possible_matches(ext_item_id, possible_matches)
    @log.debug "deleting old matches"
    repository(:default).adapter.execute('DELETE FROM possible_matches WHERE external_item_id = ?', [ext_item_id])
    @log.debug "inserting new matches"
    possible_matches.each do |pm|
      PossibleMatch.create(
        :external_item_id => ext_item_id,
        :card_no => pm,
        :score => 1
      ).save
    end
  end
end

XtnMatcher.new().start()


