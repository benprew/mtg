require 'pathname'
require 'rubygems'

gem 'rspec', '>=1.1.11'
require 'spec'

$:.unshift File.dirname(__FILE__) + '/../lib'
SPEC_ROOT = Pathname(__FILE__).dirname.expand_path
# require SPEC_ROOT + 'fixtures/tables'
