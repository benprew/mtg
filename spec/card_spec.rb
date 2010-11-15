require 'spec_helper'
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
    Cardset.insert(:name => 'test set', :cardset_import_id => 'TEST_SET')
    Card.insert(
      :name => 'test card',
      :cardset_id => Cardset.first.id,
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

end
