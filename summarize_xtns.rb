#!/usr/local/ruby/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'logger'
require 'sinatra/base'
include Sinatra::Delegator

options = {}

OptionParser.new do |op|
  op.on('-e env')    { |val| set :environment, val.to_sym }
end.parse!

# have to require the db after setting the environment
require 'mtg/sql_db'

class XtnSummarizer < Logger::Application

  include SqlDb

  def initialize
    super('XtnSummarizer')
    set_log('/tmp/summarize_xtns.rb.log', 10, 2048000)
  end

  def run
    @log.info "Deleting xtns"
    db[:xtns].delete
    
    @log.info "Inserting new xtns"
    db << %Q{
    INSERT INTO xtns
      SELECT card_no, date(end_time), external_item_id, price, 'AUCTION', cards_in_item
      FROM external_items
      WHERE card_no IS NOT NULL AND price IS NOT NULL AND cards_in_item <> 0}
    
    @log.info "Deleting xtns_by_card_day"
    db << "DELETE FROM xtns_by_card_day"
    
    @log.info "Inserting into xtns_by_card_day"
    db << %Q{
    INSERT INTO xtns_by_card_day
      SELECT card_no, date, sum(price) as price, sum(xtns) as xtns
      FROM xtns
      GROUP BY card_no, date}

    @log.info "Deleting card_prices"
    db << "DELETE FROM card_prices"

    @log.info "Inserting into card_prices"
    db << %Q{
    INSERT INTO card_prices
      SELECT card_no, sum(price) / sum(xtns)
      FROM xtns_by_card_day
      WHERE
        date >= date_sub(curdate(), interval 16 day)
      GROUP BY card_no}
  end
end

XtnSummarizer.new().start()
