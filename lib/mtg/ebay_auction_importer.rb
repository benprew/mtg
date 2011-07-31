require 'logger'
require 'mtg/importer_utils'
require 'mtg/models/external_item'
require 'rest_client'
require 'uri'
require 'json'
require 'pp'


class String
  def remove_non_ascii(replacement="")
    self.gsub(/\P{ASCII}/,replacement)
  end
end

class EbayAuctionImporter < Logger::Application

  MAX_PAGES = 100;

  include ImporterUtils

  attr_accessor :current_time

  def initialize(options = OpenStruct.new)
    super(self.class)
    set_log("/tmp/#{File.basename $0}.log", 10, 2048000)
    @current_page = 0
    @items = []
    @categories_to_check = options.categories || []
    @output_file = options.outputfile
    @log.level = options.debug ? Logger::DEBUG : Logger::INFO;

    @items_params = {
      'SECURITY-APPNAME' => app_id,
      'OPERATION-NAME' => 'findItemsAdvanced',
      'SERVICE-VERSION' => '1.9.0',
      'RESPONSE-DATA-FORMAT' => 'JSON',
      'paginationInput.entriesPerPage' => 100,
      :sortOrder => 'StartTimeNewest'
    }
  end

  def run

    @current_time = JSON.parse(RestClient.get(url_ify( gateway,
          :appid => app_id,
          :version => 595,
          :responseencoding => 'JSON',
          :callname => 'GeteBayTime' )).to_s)['Timestamp']

    @log.info "Current Time: " + @current_time
    total_items_created = 0
    total_items = 0
    while @categories_to_check.length > 0 do
      @items_params[:categoryId] = @categories_to_check.shift
      @total_pages = nil
      @current_page = 0
      begin
        item = next_item
        total_items_created += 1 if import_item(item)
        total_items += 1
      end while has_more_items?
    end

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
    @items.length > 0 || @current_page < [ MAX_PAGES, @total_pages ].min
  end

  def next_item
    if @items.length == 0
      @current_page += 1
      @items_params['paginationInput.pageNumber'] = @current_page
      @items += items_from_query(@items_params)
    end
    @items.shift
  end

  def items_from_query(params)
    result = parsed_result(url_ify(finding_gateway, params))
    if @output_file
      File.open(@output_file, 'a') { |f| f << result.pretty_inspect }
    end
    result['findItemsAdvancedResponse'][0]['searchResult'][0]['item']
  end

  def total_pages_from_query(params)
    result = parsed_result(url_ify(finding_gateway, params))
    result['findItemsAdvancedResponse'][0]['paginationOutput'][0]['totalPages'][0].to_i
  end

  def parsed_result(url)
    @log.debug(url)
    result = ''
    begin
      result = RestClient.get(url).to_s
    rescue RestClient::BadRequest
      @log.fatal("Error processing request: #{url}")
      raise
    end
    JSON.parse(result)
  end

end
