module Relevance
  module Tarantula

    # This fuzzer, would fill the known parameter on the RestRoute with the input from the attack
    # object. (with uri.encoded)
    class RestValuesFuzzer < RestParametersFuzzer

      def initialize(rest_route, attack)
        super.initialize(rest_route, attack)
        super.expected_status_codes = %w(400 403 404 422)
      end

      def generate_data
        # What to generate if we dont have known parameters
        return if rest_route.params.nil?

        # For every keys in the parameter, fill it in with the attack.input
        known_params = rest_route.params
        generated_params = Hash.new
        known_params.each do |param|
          generated_params[param] = URI.encode(attack.input)
        end

        generated_params
      end

    end

  end
end
