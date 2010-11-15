require 'spec_helper'
require 'mtg'
require 'mtg/trie_matcher'
require 'mtg/sql_card'

describe TrieMatcher do
  it 'can build a trie' do
    db.run('begin transaction')
    Cardset.insert(:name => 'test set', :cardset_import_id => 'TEST_SET')
    Card.insert(
      :name => 'test card',
      :cardset_id => Cardset.first.id,
      :collector_no => 25 )
    
    @matcher = TrieMatcher.new("log")
    db.run('rollback')
  end
end
