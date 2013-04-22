module Relevance
  module Tarantula

    # Monkey patch the result class to have a rest_route
    class Result
      attr_accessor :fuzzer
    end

    # Response handler for the json response from the REST api.
    class RestJSONResponseHandler

      class << self
        def handle(result)
          return_value = result.dup

          # Make sure return the result with successful state and populate the right result
          # description
          return_value.success = successful?(result)
          unless return_value.success
            if result.response
              return_value.description = "Unexpected HTTP Response #{result.response.code}"
            else
              return_value.description = "HTTP Request to #{result.url} does not have any response"
            end
          end

          return_value
        end

        def successful?(result)
          # result false if the result does not have a response or result does not respond to
          # :fuzzer because it is monkey patched to enable having fuzzer knowing what is the expected status code
          # and the result's object access to the fuzzer.
          return false unless result.response and result.respond_to? :fuzzer  and result.fuzzer

          # compare whether the status code from the result object is one of the expected results
          # from the fuzzer.
          fuzzer = result.fuzzer
          code = result.response.code
          fuzzer.expected_status_codes.include? code
        end
      end

    end

  end
end
