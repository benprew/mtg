require 'spec_helper'
require 'mtg'
require 'mtg/trie_matcher'
require 'mtg/models/card'

describe TrieMatcher do
  it 'can build the matcher' do
    Cardset.insert(:name => 'test set1', :cardset_import_id => 'TEST_SET')
    Card.insert(
      :name => 'test card',
      :cardset_id => Cardset.first.id,
      :collector_no => 25 )
    
    @matcher = TrieMatcher.new("log")
  end

  it "can insert a string" do
    @t = Hash.new
    @t.insert_as_trie "This is a test string", 125
    @t.insert_as_trie "This is not a test string", 126
    prefix = @t['This']
    prefix = prefix['is']
    prefix[:ids].length.should == 2

    prefix['a'][:ids].should == [125]
  end

end
