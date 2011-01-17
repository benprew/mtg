require 'spec_helper'
require 'rack/test'
require 'mtg'
require 'mtg/sql_db'

describe Cardset do

  include Rack::Test::Methods
  include SqlDb

  def app
    Sinatra::Application
  end

  it "has a set_id that can be different from the set name" do
    Cardset.insert(
      :name => 'M10',
      :cardset_import_id => 'MAGIC_2010' )
    Cardset.first.name.should == 'M10'
    Cardset.first.cardset_import_id.should == 'MAGIC_2010'
  end
end
