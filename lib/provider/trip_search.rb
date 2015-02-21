module TripSearch

  class Search
    attr_accessor :from, :date, :passengers, :max_price, :hide_full

    def initialize(params = {})
      @from = params[:from]
      @date = params[:date] || Time.now.strftime("%Y-%m-%d")
      @passengers = params[:passengers] || 1
      @max_price = params[:max_price] || 9999
      @hide_full = params[:hide_full] || true
    end
  end

  class Link
    attr_accessor :provider, :city, :departure, :arrival, :price, :free
  end

  module Provider

    require 'open-uri'
    require 'mechanize'

    class Provider

      def self.name
        "Abstract Provider"
      end

      def self.locations
        {}
      end

      def self.url(search, location)
        ""
      end

      def self.find(search_class_object)

      end

      def self.find(search)
        pass_count = search.passengers
        max_price = search.max_price
        hide_full = search.hide_full
        locations = self.locations
        links = []
        locations.each do |loc|
          next if search.from==loc[0]
          agent = Mechanize.new
          page = agent.get self.url(search, loc[0])
          links += parse_page(page, search, loc[1])
        end
        links
      end

      private
        def self.parse_page(page)
          []
        end

    end

    class StudentAgency < Provider

      def self.name
        "Student Agency"
      end

      def self.url(search, location)
        "https://jizdenky.studentagency.cz/m/Booking/from/#{search.from}/to/#{location}/tarif/REGULAR/departure/#{search.date}/return/false/ropen/false/"
      end

      def self.locations
        arr = {}
        url = 'http://www.studentagency.cz/sys/jsp/homepage-online-reservation/widget-reservation-bus-ticket.jsp?v=2123630610'
        page = Nokogiri::HTML(open(url).read)
        options = page.css('div#from_destination_sel_itn_div select optgroup option')
        options.each do |option|
          arr[option[:value]] = option.text
        end
        arr
      end

      private

        def self.parse_page(page, search, location)
          links = []
          wat = page.search('.detail-tabs .line')
          unless wat.nil?
            wat.each do |line|
              link = TripSearch::Link.new
              link.provider = TripSearch::Provider::StudentAgency
              link.city = location
              link.departure = line.search('.line-link .departure').text
              link.arrival = line.search('.line-link .arrival').text
              link.free = line.search('.line-link .free').text[/\d+/]
              next if search.hide_full == "1" && link.free && link.free == "0"
              link.price = line.search('.line-link .price').text.gsub(" ", "").gsub(/&nbsp;/i,"")[/\d+/]
              next if search.max_price && link.price && Integer(link.price) > Integer(search.max_price)
              links << link
            end
          end
          links
        end

        def self.parse_line

        end

    end

  end

end