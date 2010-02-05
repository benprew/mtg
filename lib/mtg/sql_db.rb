require 'rubygems'
require 'sequel'

module SqlDb
  module_function

  @@DB = nil

  def db
    return @@DB unless @@DB.nil?

    configure :test do
      @@DB =  Sequel.connect('sqlite:///tmp/mtg_test_db')
    end

    configure :production do
      @@DB = Sequel.connect('mysql://mtg:Tub3rz@localhost/mtg')
    end

    configure :development do
      @@DB = Sequel.connect('mysql://mtg:Tub3rz@localhost/mtg')
    end

    return @@DB
  end
end
