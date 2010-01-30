require File.dirname(__FILE__) + '/base'
require 'mtg/db'
require 'mtg/card'

describe Card do
  it "has a path to an image" do
    new_card = Card.create(
      :name => 'test card',
      :set_name => 'test set',
      :collector_no => 25 )

    new_card.picture.should == '/sets/test_set/25.jpeg'
  end
end
