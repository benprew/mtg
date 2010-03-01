require File.dirname(__FILE__) + '/base'
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
      [ ] price on card detail page should be using card_prices table
      [ ] reporting by ebay userid
      [ ] re-work main page to be same as monthly dashboard
      [ ] should use Sequel for everything
    }
  end

end
