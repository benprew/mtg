ENV['RACK_ENV'] = 'test'
$:.unshift File.dirname(__FILE__) + '/../lib'
$:.unshift File.dirname(__FILE__) + '/../'
require 'rubygems'
require 'rspec'

