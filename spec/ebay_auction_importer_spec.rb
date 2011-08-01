require 'spec_helper'
require 'time'
require 'mtg/ebay_auction_importer'
require 'mtg/models/external_item'

describe EbayAuctionImporter do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    @i = EbayAuctionImporter.new
  end

  it "can import an item" do
    item_info = {
      'itemId' => ['123456'],
      'title' => ['test item'],
      'listingInfo' => [{'endTime' => ['20100101']}],
      'sellingStatus' => [{'convertedCurrentPrice' => [{ '__value__' => 2 }]}],
    }

    @i.current_time = '20100101 10:00:00'
    @i.import_item(item_info)
    ExternalItem.count.should == 1
    @e = ExternalItem.first
    @e.should == ExternalItem.new(
      :id                       => 1,
      :external_item_id         => '123456',
      :description              => 'test item',
      :end_time                 => Time.local(2010, 01, 01, 0, 0, 0),
      :auction_price            => 2,
      :buy_it_now_price         => nil,
      :card_id                  => nil,
      :last_updated             => @e.last_updated,
      :cards_in_item            => 1,
      :price                    => nil,
      :has_been_finalized       => 0,
      :has_match_been_attempted => 0
    )
  end

  it "has more items" do
    ebay_items = Marshal.load File.new(File.dirname(__FILE__) + '/ebay_find_results.dat')
    @i.stub!(:parsed_result).and_return(ebay_items)
    @i.has_more_items?.should == true
  end

  it "can get a list of items" do
    ebay_items = Marshal.load File.new(File.dirname(__FILE__) + '/ebay_find_results.dat')
    @i.stub!(:parsed_result).and_return(ebay_items)
    @i.next_item['itemId'][0].should eq "330545248079"
    @i.next_item['itemId'][0].should eq "330545248072"
  end
end

