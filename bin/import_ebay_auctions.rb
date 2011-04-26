#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'optparse'
require 'sinatra/base'
include Sinatra::Delegator

options = OpenStruct.new

OptionParser.new do |op|
  op.on('-e env')        { |val| set :environment, val.to_sym }
  op.on('-c categories') { |val| options.categories = [ val ] }
  op.on('-o output-file') { |val| options.outputfile = val }
  op.on('-d', 'print debug output') { |val| options.debug = val }
end.parse!

# have to require the db after setting the environment
require 'mtg/ebay_auction_importer'


# from http://pages.ebay.com/categorychanges/toys.html
options.categories ||= %W{ 19107 49181 38292 158754 158755 158756 158757 158758 158759 158760 19115 }

EbayAuctionImporter.new(options).start()

