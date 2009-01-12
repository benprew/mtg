#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'rest_client'
require 'uri'
require 'json'
require 'dm-core'
require 'mtg/db'
require 'mtg/external_item'

app_id = 'BenPrew2f-def9-421f-87b8-55dc6a53837'
ebay_api_version = 595
gateway = 'http://open.api.ebay.com/shopping'

def url_ify(gateway, params)
  url = gateway + params.inject('?') { |r, e| r + "#{e[0]}=#{URI.escape e[1].to_s}&" }
  url.chop
end

@@current_time = JSON.parse(RestClient.get(url_ify( gateway,
                        :appid => app_id,
                        :version => ebay_api_version,
                        :responseencoding => 'JSON',
                        :callname => 'GeteBayTime' )))['Timestamp']

items = ExternalItem.all(:end_time.lt => @@current_time, :has_been_finalized => false)

while (items.length > 0) do
  warn "getting 20 items " + items.length.to_s
  data = JSON.parse(RestClient.get( url_ify(
    gateway,
    :appid => app_id,
    :version => ebay_api_version,
    :responseencoding => 'JSON',
    :callname => 'GetItemStatus',
    :ItemId =>items.slice!(0,20).map { |i| i.external_item_id }.join(",")
  )))

  data['Item'].each do |i|
    e = ExternalItem.get(i['ItemID'])
    e.has_been_finalized = true
    e.last_updated = @@current_time
    
    if i.has_key?('BidCount') && i['BidCount'] > 0
      warn "updating price for #{i['ItemID']}"
      e.price = i['ConvertedCurrentPrice']['Value']
    end

    e.save
  end
end





