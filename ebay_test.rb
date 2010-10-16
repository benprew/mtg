#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'rest_client'
require 'uri'
require 'json'
require 'dm-core'
require 'mtg/db'
require 'mtg/external_item'

class String
  def remove_non_ascii(replacement="") 
    self.gsub(/[\x80-\xff]/,replacement)
  end
end

dev_id = 'f36af579-ed91-4c03-b429-0507fae12064'
app_id = 'BenPrew2f-def9-421f-87b8-55dc6a53837'
cert = 'efd1bf35-147f-4584-8922-b89a3e3c3673'

auth_token = 'AgAAAA**AQAAAA**aAAAAA**ekJRSQ**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wJnYajCZCCpAmdj6x9nY+seQ**tYoAAA**AAMAAA**5IRpphHUAdfCeSL51ajiGh75IJu9JNuK5e1Pi2nUr/rMWWu/1rDT79ztHaAeVePs95SMxuuGT+L4tIKuHzJw2lxo2Qvq+uZ+OwrgLvmQDQpvpp8hFM3do3cAiO7Favb5qb6wsNCGMPYeIXFPa8bw7nTJ9zdfa0pS1E7YbGlTWaKwflQlvpJhQrRAOyJFNEhTCHYTmTN/T+NLFQ4tawjhzRDTihpOTnOprYOLzEGX7VSoojwZtNm2KAs9AWcYRnb5YyCtyFIYs53KuaI5y13F9dZRvKyTetS1Qd1TDGBxG58d5i2tc3I7APhRfDQRbexQc0O+qrRQyLW3DNFkHh0jGhviGnzb/PY62OqwXsYDVyfPxanEdXadaGg5vXSAqSeabhwbX5v6Tj7yTDtytfrHkKE2jKykOZXy59T1Y7ZCaMPgrRt4+zUNpEIb6dUIqpC26MZPHloVv4sOi/Wf5tYWjE8s/O/mD/YJdA/bCFo0pzWG2F2CoFHOWDlHe6msLrfHXVjs+Gs/EaNU4o5pgdg4/He3dLz4HyMDHM5OO9rCFlqjvs0IEY8ewe0V/4zLNtIufVasQ0zdxkw8dYMxjDpxNAD2J0xBOcYmOS7GV4cS3/pA1vQNQ68Dfv7LpiShw5py2u8I0ReKcOSGzg56sDgawwEQOtrlTMPyWFK7Vh+uYj0s0y3Tpvo4vXwIcbf+MFX1SDrjjjmrFMN7WP36R4nKiPA2wUx1nKZZ+Tjbqd0cLbB6SZ/phjiSzfJkAB348ck6'

gateway = 'http://open.api.ebay.com/shopping'

def url_ify(gateway, params)
  url = gateway + params.inject('?') { |r, e| r + "#{e[0]}=#{URI.escape e[1].to_s}&" }
  url.chop
end

def import_item(item_info)
  item = ExternalItem.first(:external_item_id => item_info['ItemID']) || ExternalItem.new(:external_item_id => item_info['ItemID'], :last_updated => @@current_time)
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
                        :callname => 'GeteBayTime' )))['Timestamp']

p @@current_time



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
result = RestClient.get(url)
data = JSON.parse(result)
p "##### Total Pages " + data['TotalPages'].to_s + "###########"

while( page_number <= data['TotalPages'] ) do
  data['SearchResult'][0]['ItemArray']['Item'].each { |i| import_item(i) }
  page_number += 1
  warn page_number

  url = url_ify( gateway,
                 :appid => app_id,
                 :version => 595,
                 :responseencoding => 'JSON',
                 :callname => 'FindItemsAdvanced',
                 :CategoryID => 38292,
                 :MaxEntries => 100,
                 :PageNumber => page_number )

  result = RestClient.get(url)
  data = JSON.parse(result)
end


 
