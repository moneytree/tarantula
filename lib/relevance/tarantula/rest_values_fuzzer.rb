module Relevance
  module Tarantula

    # This fuzzer, would fill the known parameter on the RestRoute with the input from the attack
    # object. (with uri.encoded)
    class RestValuesFuzzer < RestParametersFuzzer

      class << self
        # For every attack registered on this fuzzer, create a different fuzzer.
        def mutate(rest_route)
          return [] if rest_route.params.nil?

          # Calling super here doesnt really work,
          # generate_data method of this instance does not get call, instead the super will be called.
          attacks.map{|attack| new(rest_route, attack)}
        end
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
