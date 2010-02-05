require File.dirname(__FILE__) + '/base'
require 'mtg'
require 'rack/test'
require 'mtg/sql_db'

set :environment, :test

describe ExternalItem do

  include Rack::Test::Methods
  include SqlDb
  include CardUtils

  def app
    Sinatra::Application
  end

  before(:each) do
    db.run('begin transaction')
    db[:external_items].insert(
      :external_item_id => 1234,
      :price => 20,
      :last_updated => '20090101' )
  end

  after(:each) do
    db.run('rollback')
  end

  it "can get an auction to match" do
    get '/match_auction'

    last_response.headers["Location"].should == '/match_auction/1234'
  end

end
