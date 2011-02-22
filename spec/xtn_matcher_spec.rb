require 'spec_helper'
require 'mtg'
require 'mtg/xtn_matcher'
require 'mtg/models/card_price'
require 'mtg/models/card'

describe XtnMatcher do
  before(:each) do
    @matcher = XtnMatcher.new
  end

  it 'determines number of cards in description' do
    @matcher._cards_in_description('$ MTG $ Magic 2010 x1 Cudgel Troll - FOIL GREAT DEAL').should == 1
  end

  it "won't ever return cards > 100" do
    @matcher._cards_in_description('x101').should == 1
    @matcher._cards_in_description('101x').should == 1
    @matcher._cards_in_description('2010 x').should == 1
  end

  it "will match a card" do
    Card.insert( :name => 'test card' )
    @card = Card.first
    ExternalItem.insert(
      :description => 'test card',
      :price => 8,
      :external_item_id => '1',
      :last_updated => Time.now())
    @matchable_item = ExternalItem.first
    @matcher._match_card(@matchable_item, @card.id)

    @matchable_item.reload.card_id.should == @card.id
    
  end

  it "won't match an auction that is outside the range of the card price" do
    Card.insert( :name => 'test card' )
    @priced_card = Card.first
    CardPrice.insert(:card_id => @priced_card.id, :price => 1.99)
    ExternalItem.insert(
      :description => 'test card',
      :price => 8,
      :external_item_id => '1',
      :last_updated => Time.now())
    @unmatchable_item = ExternalItem.first

    lambda { @matcher._match_card(@unmatchable_item, @priced_card.id) }.should raise_error RuntimeError
  end
end
