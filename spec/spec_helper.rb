ENV['RACK_ENV'] = 'test'
$:.unshift File.dirname(__FILE__) + '/../lib'
$:.unshift File.dirname(__FILE__) + '/../'
require 'rubygems'
require 'rspec'
require 'sequel'
require 'sequel/extensions/migration'
require 'rack/test'
require 'mtg/sql_db'

include SqlDb

Sequel::Migrator.apply(db, 'migrations')

require 'mtg'

RSpec.configure do |c|

  c.around(:each) do |example|
    DB.transaction do
      begin
        example.run
      ensure
        raise Sequel::Rollback
      end
    end
  end
end
