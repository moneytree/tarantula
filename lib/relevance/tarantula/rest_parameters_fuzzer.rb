module Relevance
  module Tarantula

    # This fuzzer would try to create a random number of key-and-value pair, which keys and values are also totally random
    # and could be crap and send those as a HTTPrequest to the designated url.
    class RestParametersFuzzer
      include Relevance::Tarantula

      attr_accessor :rest_route, :url, :data, :attack, :expected_status_codes

      class << self
        def attacks
          # If there is no @attacks value yet, initialise with the instance of RestBasicAttack first.
          @attacks ||= [RestBasicAttack.new]

          # normalize from hash input to Attack
          # So it possible to do
          # RestParametersFuzzer.attacks <<
          # {
          #   :input => "Input for every parameters keys"
          #   :name => "Just the name of the attack"
          # }
          # And the hash would be used to instantiate the Relevance::Tarantula::Attack object.
          @attacks = @attacks.map do |val|
            Hash === val ? Relevance::Tarantula::Attack.new(val) : val
          end
          @attacks
        end

        def attacks=(atts)
          raise 'Attacks has to be an array.' unless atts.kind_of? Array
          @attacks = atts
        end

        # For every attack registered on this fuzzer, create a different fuzzer.
        def mutate(rest_route)
          attacks.map{|attack| new(rest_route, attack)}
        end
      end

      def initialize(rest_route, attack)
        @rest_route = rest_route
        @url = rest_route.url
        @attack = attack

        # Data would generate the random data and would pre-fill the default expected status codes
        @data = generate_data
        @expected_status_codes = %w(400 422)
      end

      # This method name is not really clear, even if it doesn't do "crawl", but this method
      # would be called by the "crawler" to "crawl" or make the request to the server.
      # This method is named to match with the other fuzzer "form_submission.rb" to work with
      # the rest of the Tarantula framework
      def crawl
        # Request the url with the method, url and the parameters data
        response = rest_route.crawler.submit(rest_route.method, url, data)
        code = response.code unless response.nil?
        log "Response #{code} for #{self}"

        # Then, handle the result and return the response.
        rest_route.crawler.handle_rest_fuzzer_results(self, response)
        response
      end

      # Generate the data to be posted as the HTTP body when
      # sending the request to the url
      def generate_data
        # Instantiate the basic attack as our random generator feeder
        random_generator = RestBasicAttack.new

        # Randomise the number of keys-and-values pair
        # Then, create the randomise keys and value.
        param_count = random_generator.random_number(50)
        params = Hash.new
        param_count.times do
          params[random_generator.random_string] = attack.input
        end

        params
      end

      # A form's signature is what makes it unique (e.g. action + fields)
      # used to keep track of which forms we have submitted already
      def signature
        # Its possible to not have the params associated with the fuzzer, if thats the case,
        # Make the data_keys blank array.
        data_keys = data and data.kind_of? Hash ? data.keys.sort : []
        [url, rest_route.method, data_keys, attack]
      end

      def to_s
        "#{url} - #{rest_route.inspect}"
      end

    end

  end
end
