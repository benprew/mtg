#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'optparse'
require 'sinatra/base'
include Sinatra::Delegator

options = {}

OptionParser.new do |op|
  op.on('-e env')    { |val| set :environment, val.to_sym }
end.parse!

# have to require the db after setting the environment
require 'mtg/ebay_auction_importer'

EbayAuctionImporter.new().start()
