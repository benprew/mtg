require 'rubygems'
require 'sequel'
require 'yaml'
require 'sinatra/base'

include Sinatra::Delegator

module SqlDb
  DB_CONFIG = YAML::load File.open(File.dirname(__FILE__) + '/../../config/database.yml')

  def db
    return DB
  end

  def build_connect_string_for(environment)
    db_info = DB_CONFIG[environment.to_s]
    return sprintf "%s://%s:%s@localhost/%s", db_info['adapter'], db_info['username'], db_info['password'], db_info['database']
  end

  module_function :db, :build_connect_string_for
end

if test?
  DB = Sequel.sqlite
elsif production?
  DB = Sequel.connect(SqlDb.build_connect_string_for(:production))
else
  DB = Sequel.connect(SqlDb.build_connect_string_for(:development))
end

