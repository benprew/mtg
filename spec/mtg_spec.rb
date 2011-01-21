require 'spec_helper'
require 'rack/test'
require 'mtg'
require 'mtg/sql_db'
require 'mtg/sql_card'
require 'mtg/cardset'

describe Card do

  include Rack::Test::Methods
  include SqlDb

  def app
    Sinatra::Application
  end

  it "should search" do
    Cardset.insert( :name => 'test set' )
    Card.insert(
      :name => "Uwezima's Jitte",
      :cardset_id => Cardset.first.id
    )
    get '/search', :q => 'Jitte'
    last_response.body.should =~ /Jitte/
  end

  it "should do" do
    puts %Q{
      [ ] create foil cards for rise of eldrazi and scars of mirrodin
      [ ] fix rise from the grave auctions

      [ ] should use Sequel for everything

      [ ] store stddev on card_prices for more accurate matching

      [ ] create way to embded datasets possibly by just using div-id?  ie http://mtg.throwingbones.com/datasets/cards-by-price?cardset_id=123  Then the div named cards-by-price would call that dataset
      [ ] prices on dashboard should all be using card_prices
      [ ] reporting by ebay userid
      [ ] re-work main page to be same as monthly dashboard
    }
  end

end
