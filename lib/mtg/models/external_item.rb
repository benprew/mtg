require 'rubygems'
require 'sequel'
require 'mtg/sql_db'

class ExternalItem < Sequel::Model
  unrestrict_primary_key
end
