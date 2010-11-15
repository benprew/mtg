require 'rack/test'
require 'mtg'
require 'mtg/sql_db'

describe Card do

  include Rack::Test::Methods
  include SqlDb

  def app
    Sinatra::Application
  end

  it "should do" do
    puts %Q{
      [ ] create way to embded datasets possibly by just using div-id?  ie http://mtg.throwingbones.com/datasets/cards-by-price?cardset_id=123  Then the div named cards-by-price would call that dataset
      [x] price on card detail page should be using card_prices table
      [ ] prices on dashboard should all be using card_prices
      [ ] reporting by ebay userid
      [ ] re-work main page to be same as monthly dashboard
      [ ] should use Sequel for everything
    }
  end

end
