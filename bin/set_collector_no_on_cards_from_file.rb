#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'mtg/sql_db'

include SqlDb

open(ARGV[0], 'r').each do |line|
  (collector_no, card_name) = line.chomp.split(/\|/)
  next unless collector_no && card_name
  puts "Updating '#{card_name}'"
  db[:cards].filter(:name => card_name).update(:collector_no => collector_no)
  db[:cards].filter(:name => card_name + ' Foil').update(:collector_no => collector_no)
end


