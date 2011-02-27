#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'bundler/setup'
require 'optparse'
require 'sinatra/base'
include Sinatra::Delegator

options = {}

OptionParser.new do |op|
  op.on('-e env')    { |val| set :environment, val.to_sym }
end.parse!

# have to require the db after setting the environment
require 'mtg/xtn_matcher'

XtnMatcher.new().start()


