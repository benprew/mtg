require 'spec_helper'
require 'mtg'
require 'rack/test'

describe ExternalItem do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "can get an auction to match" do
    ExternalItem.create(
      :external_item_id => 1234,
      :price            => 20,
      :description      => 'test item',
      :last_updated     => '20090101' )

    get '/match_auction'

    last_response.headers["Location"].should == 'http://example.org/match_auction/1234'
  end

  it "can show an auction to match properly" do
    ExternalItem.create(
      :external_item_id => 1234,
      :price            => 20,
      :description      => 'test item',
      :last_updated     => '20090101' )

    get '/match_auction/1234'

    last_response.body.should match /Match the auction below/
  end


end
