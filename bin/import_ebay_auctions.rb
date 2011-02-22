#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'bundler'
Bundler.setup

require 'rest_client'
require 'uri'
require 'json'
require 'mtg/models/external_item'

class String
  def remove_non_ascii(replacement="") 
    self.gsub(/[\x80-\xff]/,replacement)
  end
end

dev_id = 'f36af579-ed91-4c03-b429-0507fae12064'
app_id = 'BenPrew2f-def9-421f-87b8-55dc6a53837'
cert = 'efd1bf35-147f-4584-8922-b89a3e3c3673'
gateway = 'http://open.api.ebay.com/shopping'

def url_ify(gateway, params)
  url = gateway + params.inject('?') { |r, e| r + "#{e[0]}=#{URI.escape e[1].to_s}&" }
  url.chop
end

def import_item(item_info)
  item = ExternalItem.find_or_create(:external_item_id => item_info['ItemID']) { |i| i.last_updated = @@current_time }
  item.description = item_info['Title'].remove_non_ascii
  item.end_time = item_info['EndTime']
  item.auction_price = item_info['ConvertedCurrentPrice']['Value']
  item.buy_it_now_price = item_info['ConvertedBuyItNowPrice']['Value'] if item_info['ConvertedBuyItNowPrice']

  item.save
end


@@current_time = JSON.parse(RestClient.get(url_ify( gateway,
                        :appid => app_id,
                        :version => 595,
                        :responseencoding => 'JSON',
                        :callname => 'GeteBayTime' )).to_s)['Timestamp']



# from http://pages.ebay.com/categorychanges/toys.html
# mtg_singles_cat_id = 38292

url = url_ify( gateway,
               :appid => app_id,
               :version => 595,
               :responseencoding => 'JSON',
               :callname => 'FindItemsAdvanced',
               :CategoryID => 38292,
               :MaxEntries => 100
)

page_number = 1
puts "Current Time: " + @@current_time
data = JSON.parse(RestClient.get(url).to_s)
puts "Total Pages: " + data['TotalPages'].to_s
puts "Total Items: " + (data['TotalPages'] * 100).to_s


while( page_number <= data['TotalPages'] ) do
  data['SearchResult'][0]['ItemArray']['Item'].each { |i| import_item(i) }
  page_number += 1
  puts "Working on Page: #{page_number}"

  url = url_ify( gateway,
                 :appid => app_id,
                 :version => 595,
                 :responseencoding => 'JSON',
                 :callname => 'FindItemsAdvanced',
                 :CategoryID => 38292,
                 :MaxEntries => 100,
                 :PageNumber => page_number )

  result = RestClient.get(url)
  data = JSON.parse(result.to_s)
end

