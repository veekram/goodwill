require 'mechanize'

require 'goodwill/csspaths'
require 'goodwill/urlpaths'
require 'goodwill/mechanize'

module Goodwill
  class Auction
    include Goodwill::Mechanize
    include CSSPaths
    include URLPaths

    attr_reader :bids
    attr_reader :current
    attr_reader :end
    attr_reader :href
    attr_reader :item
    attr_reader :itemid
    attr_reader :seller
    attr_reader :shipping

    def initialize(itemid, zipcode = '97222', state = 'OR', country = 'United States')
      @itemid = itemid
      @zipcode = zipcode
      @state = state
      @country = country

      @href = ITEM_SEARCH_URL + itemid.to_s
      item_page = mechanize.get(@href)
      @bids = item_page.search(BIDS_PATH).text[/\d+/]
      @current = item_page.search(CURRENT_PRICE_PATH).text
      @end = item_page.search(END_TIME_PATH).text
      @item = item_page.search(ITEM_TITLE_PATH).text
      @seller = item_page.search(SELLER_PATH).text
      @bidding = false
      @shipping = calculate_shipping(@itemid, @zipcode, @state, @country)
    end

    def ==(another_auction)
      self.itemid == another_auction.itemid
    end

    private

    def calculate_shipping(itemid, zipcode, state, country)
      params = "?itemid=#{itemid}&zip=#{zipcode}&state=#{state}&country=#{country}"
      page = mechanize.get(SHIPPING_URL + params)
      page.search(SHIPPING_PATH).text
    end
  end
end
