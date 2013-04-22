module Relevance
  module Tarantula

    # Provides a kind of random generator values, number, int, or even the random strings
    class RestBasicAttack < BasicAttack
      extend Forwardable

      # :random_number on the BasicAttack would call the random_number on the SecureRandom class.
      def_delegator :SecureRandom, :random_number

      # Also, :random_int, which is overridden from the the Basic Attack,
      # To call the SecureRandom random_number instead.
      def_delegator :SecureRandom, :random_number, :random_int

      def initialize
        @name = "Tarantula Rest Basic Fuzzer"
        @output = nil
        @description = "Supplies a random string, random integer to be used as the HTTP Body Keys and(or) Values."
      end

      def ==(other)
        RESTBasicAttack === other && self.input == other.input
      end

      def input
        random_string(50)
      end

      def random_string(length = 10)
        length = SecureRandom.random_number(length)
        characters = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a

        SecureRandom.random_bytes(length).each_char.map do |char|
          characters[(char.ord % characters.length)]
        end.join
      end

    end

  end
end
