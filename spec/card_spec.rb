require File.dirname(__FILE__) + '/base'
require 'rack/test'
require 'mtg'
require 'mtg/sql_db'

describe Card do

  include Rack::Test::Methods
  include SqlDb

  def app
    Sinatra::Application
  end

  before(:each) do
    db.run('begin transaction')
    Card.insert(
      :name => 'test card',
      :set_name => 'test set',
      :collector_no => 25 )
    @new_card = Card.first
  end

  after(:each) do
    db.run('rollback')
  end


  it "has a path to an image" do
    @new_card.picture.should == '/sets/test_set/25.jpeg'
  end

  it "can get card details" do
    get "/card/#{@new_card[:card_no]}"

    last_response.body.should match /Casting Cost/
  end

  it "can build a card chart" do
    db[:xtns_by_card_day].insert(
      :card_no => 100,
      :price => 25,
      :xtns => 1,
      :date => '20090101' )

    db[:xtns_by_card_day].insert(
      :card_no => 100,
      :price => 12,
      :xtns => 2,
      :date => '20090102' )

    get "/chart/card/100"

    last_response.body.should match(/tick_height/)
    last_response.body.should match(/values.*[25,6]/)
    last_response.body.should match(/values.*[1,2]/)
  end
end
