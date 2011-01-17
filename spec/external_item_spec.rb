require 'spec_helper'
require 'mtg'
require 'rack/test'

describe ExternalItem do

  include Rack::Test::Methods
  include SqlDb

  def app
    Sinatra::Application
  end

  it "can get an auction to match" do
    db[:external_items].insert(
      :external_item_id => 1234,
      :price => 20,
      :last_updated => '20090101' )

    get '/match_auction'

    last_response.headers["Location"].should == '/match_auction/1234'
  end

  it "can show an auction to match properly" do
    db[:external_items].insert(
      :external_item_id => 1234,
      :price => 20,
      :last_updated => '20090101' )

    get '/match_auction/1234'

    last_response.body.should match /Match the auction below/
  end


end
