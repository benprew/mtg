require 'rubygems'
require 'sequel'

module SqlDb
  module_function
  @@DB =  Sequel.connect('sqlite:///tmp/mtg_test_db')

  configure :production do
    @@DB = Sequel.connect('mysql://mtg:Tub3rz@localhost/mtg')
  end

  def db
    return @@DB
  end

end
