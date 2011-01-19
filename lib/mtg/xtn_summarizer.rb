require 'logger'
require 'date'
require 'mtg/sql_db'

class XtnSummarizer < Logger::Application

  include SqlDb

  def initialize
    super('XtnSummarizer')
    log_filename = test? ? '/tmp/test_summarize_xtns.rb.log' : '/tmp/summarize_xtns.rb.log'
    set_log(log_filename, 10, 2048000)
  end

  def run
    @log.info "Deleting xtns"
    db[:xtns].delete

    @log.info "Inserting new xtns"
    ext_items = db[:external_items].
      select(:card_id, :end_time, :external_item_id, :price, 'AUCTION', :cards_in_item).
      filter( ~:card_id => nil, ~:price => nil, ~:cards_in_item => 0)
    
    db[:xtns].insert([:card_id, :date, :external_item_id, :price, :xtn_type_id, :xtns], ext_items)

    @log.info "Deleting xtns_by_card_day"
    db << "DELETE FROM xtns_by_card_day"

    @log.info "Inserting into xtns_by_card_day"
    db << %Q{
    INSERT INTO xtns_by_card_day
      SELECT card_id, date, sum(price) as price, sum(xtns) as xtns
      FROM xtns
      GROUP BY card_id, date}

    @log.info "Deleting card_prices"
    db << "DELETE FROM card_prices"

    @log.info "Inserting into card_prices"
    db[:card_prices].insert(
      [:card_id, :price], 
      db[:xtns_by_card_day].
        select(:card_id, :SUM.sql_function(:price) / :SUM.sql_function(:xtns)).
        filter( :date >= Date.today << 1 ).
        group_by(:card_id))
  end

end

