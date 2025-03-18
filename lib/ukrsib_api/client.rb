# frozen_string_literal: true

module UkrsibAPI
  # main entry point for the gem
  # see #balances, #transactions
  class Client
    BASE_URL = "https://business.ukrsibbank.com/morpheus/"
    attr_reader :access_token, :adapter, :stubs, :auth

    # Expects UkrsibAPI::Authentication tp be already authorized
    # see documentation for UkrsibAPI::Authentication
    # @param authentication [UkrsibAPI::Authentication] authentication object
    def initialize(authentication: nil, adapter: Faraday.default_adapter, stubs: nil)
      @auth = authentication || UkrsibAPI::Authentication.new
      @adapter = adapter
      @stubs = stubs
    end

    def connection
      @auth.refresh_token_if_needed

      @connection ||= Faraday.new(BASE_URL) do |b|
        b.headers["Authorization"] = "Bearer #{@auth.access_token}"
        b.headers["Content-Type"] = "application/json;charset=utf8"
        b.ssl.verify = true
        b.request :json
        b.response :json
        b.response :logger, UkrsibAPI.logger, { headers: false, bodies: false }
        b.adapter @adapter, @stubs
      end
    end

    # Returns a new instance of UkrsibAPI::Resources::BalanceResource for handling balance-related API operations.
    # @return [UkrsibAPI::Resources::BalanceResource] The balance resource client.
    def balances
      UkrsibAPI::Resources::BalanceResource.new(self)
    end

    # Returns a new instance of UkrsibAPI::Resources::TransactionResource for handling transaction-related API operations.
    # @return [UkrsibAPI::Resources::TransactionResource] The transaction resource client.
    def statements_v3
      UkrsibAPI::Resources::StatementsV3Resource.new(self)
    end
  end
end
