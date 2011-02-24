require 'logger'
require 'mtg/importer_utils'
require 'mtg/models/external_item'
require 'rest_client'
require 'uri'
require 'json'


class String
  def remove_non_ascii(replacement="") 
    self.gsub(/[\x80-\xff]/,replacement)
  end
end

class EbayAuctionImporter < Logger::Application

  include ImporterUtils

  attr_accessor :current_time

  def initialize
    super('EbayAuctionImporter')
  end

  def import_item(item_info)
    item = ExternalItem.find_or_create(:external_item_id => item_info['ItemID']) { |i| i.last_updated = @current_time }

    item.description = item_info['Title'].remove_non_ascii
    item.end_time = item_info['EndTime']
    item.auction_price = item_info['ConvertedCurrentPrice']['Value']
    item.buy_it_now_price = item_info['ConvertedBuyItNowPrice']['Value'] if item_info['ConvertedBuyItNowPrice']

    item.save
  end

  def run
    @current_time = JSON.parse(RestClient.get(url_ify( gateway,
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
    @log.info "Current Time: " + @current_time
    data = JSON.parse(RestClient.get(url).to_s)
    @log.info "Total Pages: " + data['TotalPages'].to_s
    @log.info "Total Items: " + (data['TotalPages'] * 100).to_s


    while( page_number <= data['TotalPages'] ) do
      data['SearchResult'][0]['ItemArray']['Item'].each { |i| import_item(i) }
      page_number += 1
      @log.debug "Working on Page: #{page_number}"

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
  end
end
