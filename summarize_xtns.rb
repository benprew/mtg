#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sequel'
require 'mtg/sql_db'
require 'logger'

class XtnSummarizer < Logger::Application

  include SqlDb

  def initialize
    super('XtnSummarizer')
    set_log('/tmp/summarize_xtns.rb.log', 10, 2048000)
  end

  def run
    @log.info "Deleting xtns"
    DB[:xtns].delete
    
    @log.info "Inserting new xtns"
    DB << %Q{
    INSERT INTO xtns
      SELECT card_no, date(end_time), external_item_id, price, 'AUCTION', cards_in_item
      FROM external_items
      WHERE card_no IS NOT NULL AND price IS NOT NULL}
    
    @log.info "Deleting xtns_by_card_day"
    DB << "DELETE FROM xtns_by_card_day"
    
    @log.info "Inserting into xtns_by_card_day"
    DB << %Q{
    INSERT INTO xtns_by_card_day
      SELECT card_no, date, sum(price) as price, sum(xtns) as xtns
      FROM xtns
      GROUP BY card_no, date}

    @log.info "Deleting card_prices"
    DB << "DELETE FROM card_prices"

    @log.info "Inserting into card_prices"
    DB << %Q{
    INSERT INTO card_prices
      SELECT card_no, sum(price) / sum(xtns)
      FROM xtns_by_card_day
      WHERE
        date >= date_sub(curdate(), interval 16 day)
      GROUP BY card_no}
  end
end

XtnSummarizer.new().start()
