# frozen_string_literal: true

module UkrsibAPI
  # main entry point for the gem
  # see #balances, #transactions
  class Client
    BASE_URL = "https://business.ukrsibbank.com/morpheus/"
    attr_reader :access_token, :adapter, :stubs


    def initialize(client_id:, client_secret:, client_code:, private_key:, adapter: Faraday.default_adapter)
      # , stubs: nil
      @auth = UkrsibAPI::Authentication.new(
        client_id: client_id,
        client_secret: client_secret,
        client_code: client_code,
        private_key: private_key
      )
      @auth.fetch_token
      @adapter = adapter
      # @stubs = stubs
    end

    def connection
      @auth.refresh_token_if_needed

      @connection ||= Faraday.new(BASE_URL) do |b|
        b.headers["Authorization"] = "Bearer #{auth.access_token}"
        b.headers["Content-Type"] = "application/json;charset=utf8"
        b.ssl.verify = true
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
    def transactions
      UkrsibAPI::Resources::StatementsV3Resource.new(self)
    end
  end
end
