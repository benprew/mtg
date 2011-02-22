require 'spec_helper'
require 'mtg/models/card'

describe Card do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    Cardset.insert(:name => 'test set', :cardset_import_id => 'TEST_SET')
    Card.insert(
      :name => 'test card',
      :cardset_id => Cardset.first.id,
      :collector_no => 25 )
    @new_card = Card.first
  end

  it "has a path to an image" do
    @new_card.picture.should == '/sets/testset/testcard.jpg'
  end

  it "can get card details" do
    get "/card/#{@new_card[:id]}"

    last_response.body.should match /Casting Cost/
  end

end
