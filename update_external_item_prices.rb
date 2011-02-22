#!/usr/bin/ruby

$:.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'bundler/setup'
require 'rest_client'
require 'uri'
require 'json'
require 'mtg/models/external_item'

app_id = 'BenPrew2f-def9-421f-87b8-55dc6a53837'
ebay_api_version = 595
gateway = 'http://open.api.ebay.com/shopping'

def url_ify(gateway, params)
  url = gateway + params.inject('?') { |r, e| r + "#{e[0]}=#{URI.escape e[1].to_s}&" }
  url.chop
end

@@current_time = Time.parse(JSON.parse(RestClient.get(url_ify( gateway,
                        :appid => app_id,
                        :version => ebay_api_version,
                        :responseencoding => 'JSON',
                        :callname => 'GeteBayTime' )))['Timestamp'])

items = ExternalItem.filter('end_time < ?', @@current_time - 24 * 60 * 60).
  filter(:has_been_finalized => false).all

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





