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
    super(self.class)
    set_log("/tmp/#{File.basename $0}.log", 10, 2048000)
    @current_page = 0
    @items = []

    # from http://pages.ebay.com/categorychanges/toys.html
    # mtg_singles_cat_id = 38292
    @items_params = {
      'SECURITY-APPNAME' => app_id,
      'OPERATION-NAME' => 'findItemsAdvanced',
      'SERVICE-VERSION' => '1.9.0',
      'RESPONSE-DATA-FORMAT' => 'JSON',
      :categoryId => 38292,
      :MaxEntries => 100,
      :sortOrder => 'StartTimeNewest'
    }
  end

  def run
    @log.level = Logger::INFO

    @current_time = JSON.parse(RestClient.get(url_ify( gateway,
          :appid => app_id,
          :version => 595,
          :responseencoding => 'JSON',
          :callname => 'GeteBayTime' )).to_s)['Timestamp']

    @log.info "Current Time: " + @current_time
    total_items_created = 0
    total_items = 0
    begin
      item = next_item
      total_items_created += 1 if import_item(item)
      total_items += 1
    end while has_more_items?

    @log.info "Total Items: #{total_items} (created #{total_items_created} new items)"
  end


  def import_item(item_info)
    item = ExternalItem.find(:external_item_id => item_info['itemId'])
    item_created = false

    unless item
      item = ExternalItem.create(
        :external_item_id => item_info['itemId'],
        :last_updated => @current_time )
      item_created = true
    end

    item.description = item_info['title'][0].remove_non_ascii
    item.end_time = item_info['listingInfo'][0]['endTime'][0]
    item.auction_price = item_info['sellingStatus'][0]['convertedCurrentPrice'][0]['__value__']
    item.buy_it_now_price = item_info['ConvertedBuyItNowPrice']['Value'] if item_info['ConvertedBuyItNowPrice']

    item.save

    return item_created
  end

  def has_more_items?
    @total_pages ||= total_pages_from_query(@items_params)
    @current_page < @total_pages
  end

  def next_item
    if @items.length == 0
      @current_page += 1
      @items_params[:PageNumber] = @current_page
      @items += items_from_query(@items_params)
    end
    @items.shift
  end

  def items_from_query(params)
    result = parsed_result(url_ify(finding_gateway, params))
    result['findItemsAdvancedResponse'][0]['searchResult'][0]['item']
  end

  def total_pages_from_query(params)
    result = parsed_result(url_ify(finding_gateway, params))
    result['findItemsAdvancedResponse'][0]['paginationOutput'][0]['totalPages'][0].to_i
  end

  def parsed_result(url)
    JSON.parse(RestClient.get(url).to_s)
  end

end
