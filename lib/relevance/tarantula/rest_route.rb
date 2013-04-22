module Relevance
  module Tarantula

    # This class is used for a single rest route
    # with its URL, method, and the parameters
    class RestRoute

      attr_accessor :url, :method, :crawler, :params

      def initialize(crawler, url, method = :get, options = {})
        @crawler = crawler
        @url = url
        @method = method

        # Make sure that we have params in array.
        @params = options[:params] if options[:params] and options[:params].kind_of? Array
      end

      def to_s
        "#{url}<#{method}>"
      end

    end

  end
end
