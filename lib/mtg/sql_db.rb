require 'rubygems'
require 'sequel'
require 'yaml'

module SqlDb
  module_function

  @@DB = nil

  def db
    return @@DB unless @@DB.nil?

    db_config = YAML::load File.open(File.dirname(__FILE__) + '/../../config/database.yml')

    @@DB =  Sequel.connect('sqlite:///tmp/mtg_test_db') if test?
    @@DB = Sequel.connect(make_connect_string(db_config, :production)) if production?
    @@DB = Sequel.connect(make_connect_string(db_config, :development)) if development?

    return @@DB
  end

  def make_connect_string(db_config, environment)
    db_info = db_config[environment.to_s]
    return sprintf "%s://%s:%s@localhost/%s", db_info['adapter'], db_info['username'], db_info['password'], db_info['database']
  end

end
