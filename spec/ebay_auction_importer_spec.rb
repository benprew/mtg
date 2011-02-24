require 'spec_helper'
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
      'ItemID' => '123456',
      'Title' => 'test item',
      'EndTime' => '20100101',
      'ConvertedCurrentPrice' => { 'Value' => 1 }
    }

    @i.current_time = '20100101 10:00:00'
    @i.import_item(item_info)
    ExternalItem.count.should == 1
    @e = ExternalItem.first
  end
end

