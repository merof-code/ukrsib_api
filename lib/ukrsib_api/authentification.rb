# frozen_string_literal: true

require "faraday"
require "json"
require "time"

module UkrsibAPI
  class Authentication
    TOKEN_URL = "https://business.ukrsibbank.com/morpheus/token"

    attr_reader :client_id, :client_secret, :client_code, :private_key, :access_token, :refresh_token, :expires_at

    def initialize(client_id:, client_secret:, client_code:, private_key:)
      @client_id = client_id
      @client_secret = client_secret
      @client_code = client_code
      @private_key = OpenSSL::PKey::RSA.new(private_key) # Load RSA private key
    end

    def fetch_token
      response = Faraday.post(TOKEN_URL) do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form(
          grant_type: "client_code",
          client_id:, client_secret:, client_code:
        )
      end

      store_token(response)
    end

    def refresh_access_token
      return fetch_token if refresh_token.nil? # If no refresh token, re-authenticate

      response = Faraday.post(TOKEN_URL) do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form(
          grant_type: "refresh_token",
          refresh_token: refresh_token,
          client_id: client_id,
          client_secret: client_secret
        )
      end

      store_token(response)
    end

    def valid_token?
      access_token && expires_at && Time.now < expires_at
    end

    def refresh_token_if_needed
      return if valid_token?

      UkrsibAPI.lo "Refreshing expired token..."
      refresh_access_token
    end

    private

    def store_token(response)
      raise "Authentication failed: #{response.status} - #{response.body}" unless response.status == 200

      body = JSON.parse(response.body)
      @access_token = body["access_token"]
      @refresh_token = body["refresh_token"]
      @expires_at = Time.now + body["expires_in"].to_i # Store expiration time

      UkrsibAPI.logger.info "New access token retrieved. Expires at: #{@expires_at}"
      @access_token
    end
  end
end
