require 'rubygems'
require 'sequel'

module SqlDb
  DB = Sequel.connect('mysql://mtg:Tub3rz@localhost/mtg')
end
