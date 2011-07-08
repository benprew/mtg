$LOAD_PATH << '.'
require 'mtg'
require 'user'

path '/user' do
     run User
end

path  '/' do
    run Sinatra::Application
end

