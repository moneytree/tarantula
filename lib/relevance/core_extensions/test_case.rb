module Relevance
  module CoreExtensions

    module TestCaseExtensions
      def tarantula_crawl(integration_test, options = {})
        url = options[:url] || "/"
        t = tarantula_crawler(integration_test, options)
        t.crawl url
      end

      def tarantula_crawler(integration_test, options = {})
        Relevance::Tarantula::RailsIntegrationProxy.rails_integration_test(integration_test, options)
      end

      def tarantula_rest_fuzzer(integration_test, options = {})
        # Setup both the basic fuzzers and the basic json handlers.
        t = tarantula_crawler(integration_test, options)
        t.fuzzers = [Relevance::Tarantula::RestParametersFuzzer, Relevance::Tarantula::RestValuesFuzzer]
        t.handlers = [Relevance::Tarantula::RestJSONResponseHandler]

        # Give a nicer looking test name.
        name = self.method_name.split("_").map{|k| k.capitalize}.join(" ")
        t.test_name = "#{name}"

        # Return
        t
      end

    end

  end
end

if defined? ActionController::IntegrationTest
  ActionController::IntegrationTest.class_eval { include Relevance::CoreExtensions::TestCaseExtensions }
end
