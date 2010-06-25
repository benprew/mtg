require File.dirname(__FILE__) + '/base'
require 'mtg'
require 'mtg/xtn_summarizer'
require 'mtg/sql_db'
require 'mtg/sql_external_item'
require 'time'
require 'date'

describe XtnSummarizer do

  include SqlDb

  before(:each) do
    db.run('begin transaction')
    ExternalItem.insert(
      :external_item_id => 'ABC',
      :price => 5.0,
      :end_time => Time.now() - 1,
      :last_updated => Time.now() - 1,
      :card_no => 123,
      :cards_in_item => 1 )
    @summarizer = XtnSummarizer.new();
  end

  after(:each) do
    db.run('rollback')
  end

  it "should summarize xtns" do
    @summarizer.run()
    xtns = db[:xtns].all
    xtns.length.should == 1
    xtns[0][:price].should == 5.0
    xtns[0][:date].should == Date.today()
  end

  it "should use last rolling month for card_prices table" do
    ExternalItem.insert(
      :external_item_id => 'ABC2',
      :price => 40.0,
      :end_time => (Date.today() << 1) - 1,
      :last_updated => Time.now(),
      :card_no => 123,
      :cards_in_item => 1 )

    @summarizer.run()
    
    db[:xtns].count.should == 2
    db[:card_prices].count.should == 1
    db[:card_prices].first[:price].should == 5.0
  end
end