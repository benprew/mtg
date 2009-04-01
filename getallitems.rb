#!/usr/local/ruby/bin/ruby

require 'rubygems'
require 'rest_client'
require 'uri'
require 'json'
require 'mtg/db'
require 'mtg/external_item'

dev_id = 'f36af579-ed91-4c03-b429-0507fae12064'
cert = 'efd1bf35-147f-4584-8922-b89a3e3c3673'


def url_ify(gateway, params)
  url = gateway + params.inject('?') { |r, e| r + "#{e[0]}=#{URI.escape e[1].to_s}&" }
  url.chop
end

def item_details(external_item_id)

  app_id = 'BenPrew2f-def9-421f-87b8-55dc6a53837'
  gateway = 'http://open.api.ebay.com/shopping'

  url = url_ify(
    gateway,
    :appid => app_id,
    :version => 595,
    :responseencoding => 'JSON',
    :callname => 'GetSingleItem',
    :ItemId => external_item_id,
    :IncludeSelector => 'Details'
  )
  return RestClient.get(url)
end

ExternalItem.all(:order => [:external_item_id.desc]).each do |e|
  next if File.exist?('items/' + e.external_item_id)
  File.new('items/' + e.external_item_id, 'w').puts(item_details(e.external_item_id))
end
