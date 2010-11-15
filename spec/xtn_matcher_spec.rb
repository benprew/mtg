require 'mtg/xtn_matcher'

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
end
