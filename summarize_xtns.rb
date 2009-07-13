#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'dm-core'
require 'mtg/db'
require 'logger'

class XtnSummarizer < Logger::Application

  def initialize
    super('XtnSummarizer')
    set_log('/tmp/summarize_xtns.rb.log', 10, 2048000)
  end

  def run
    @log.info "Deleting xtns"
    repository(:default).adapter.execute("DELETE FROM xtns")
    
    @log.info "Inserting new xtns"
    repository(:default).adapter.execute(%Q{
    INSERT INTO xtns
      SELECT card_no, date(end_time), external_item_id, price, 'AUCTION', cards_in_item
      FROM external_items
      WHERE card_no IS NOT NULL AND price IS NOT NULL})
    
    @log.info "Deleting xtns_by_card_day"
    repository(:default).adapter.execute("DELETE FROM xtns_by_card_day")
    
    @log.info "Inserting into xtns_by_card_day"
    repository(:default).adapter.execute(%Q{
    INSERT INTO xtns_by_card_day
      SELECT card_no, date, sum(price) as price, sum(xtns) as xtns
      FROM xtns
      GROUP BY card_no, date})
  end
end

XtnSummarizer.new().start()
