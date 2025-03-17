# frozen_string_literal: true
# typed: true

require "faraday"
require "json"
require "time"
require "base64"

module UkrsibAPI
  class Authentication
    BASE_URL = "https://business.ukrsibbank.com/morpheus"
    TOKEN_URL = "#{BASE_URL}/token"

    attr_reader :client_params, :private_key, :tokens

    # This method sets up authentication using either `client_params` (for new authentication) or existing `tokens`
    #
    # @param private_key [String] The RSA private key in PEM format.
    # @param client_params [Hash, nil] OAuth2 client parameters for authentication.
    #   This includes `client_id`, `client_secret`.
    # @param tokens [Hash, nil] Optional. A hash containing previously acquired authentication tokens.
    #   Typically includes:
    #   - `:access_token` [String] The access token for API requests.
    #   - `:refresh_token` [String] The refresh token for obtaining a new access token.
    #   - `:expires_at` [Time] The refresh token for obtaining a new access token.
    #
    # @raise [OpenSSL::PKey::RSAError] If the private key is invalid.
    #
    # @example Initialize with client_params (fresh authentication)
    #   auth = Authenticator.new(private_key:, client_params: { client_id: "abc", client_secret: "xyz" })
    #
    # @example Initialize with tokens (existing authentication)
    #   auth = Authenticator.new(private_key:, client_params:, tokens: { access_token: "token123", refresh_token: "token456" }, expires_at: Time.now + 3600)
    def initialize(private_key:, client_params:, tokens: nil)
      @private_key = OpenSSL::PKey::RSA.new(private_key) # Load RSA private key
      @client_params = client_params&.slice(:client_id, :client_secret) if client_params
      @tokens = tokens&.slice(:access_token, :refresh_token, :expires_at) if tokens
      return unless @tokens && !@tokens[:expires_at]

      raise ArgumentError, "Missing :expires_at in tokens, it should be a Time object, e.g. Time.now + expires_in"
    end

    def access_token
      unless valid_token?
        UkrsibAPI.logger.warn "Access token is invalid or expired. Refreshing..."
        refresh_access_token
      end
      @tokens[:access_token]
    end

    # Initiates the OAuth2 authorization process. This method should be called first
    # to obtain an authorization URL to which the client should be redirected.
    #
    # @param redirect_url [String, nil] Optional URL to redirect after authorization.
    #   If provided, the authorization request includes `redirect_uri`. Otherwise,
    #   a unique `client_code` is generated.
    #
    # @return [Hash] A hash containing:
    #   - `:client_code` [String, nil] The generated client code (if no redirect URL is used).
    #   - `:location` [String] The authorization URL to which the client should be redirected.
    # after the user has authorized the client, only then must the #fetch_token method be called.
    #
    # @example Authorization with redirect URI
    #   authorize("https://example.com/callback")
    #
    # @example Authorization without redirect URI (using client_code)
    #   authorize
    def authorize(redirect_url: nil)
      UkrsibAPI.logger.warn "Already authorized, redundant call to authorize" if tokens

      params = @client_params.clone
      params[:response_type] = "code"

      if redirect_url
        params[:redirect_uri] = redirect_url
      else
        params[:client_code] = SecureRandom.uuid
      end

      url_params = URI.encode_www_form(params)
      response = Faraday.get("#{BASE_URL}/authorize?#{url_params}")
      raise Error, "Authorization request failed with #{response.status}, #{response.body}" if response.status == 400

      { client_code: params[:client_code], location: response.headers["location"] }
    end

    # Exchanges an authorization code or client code for an access token.
    #
    # It requires either a `client_code` (if no redirect URI was used) or an authorization `code`
    # if the user was redirected back after authorization.
    #
    # @param client_code [String, nil] The client code returned by the `authorize` method
    #   if no redirect URI is used.
    # @param code [String, nil] The authorization code obtained from the redirect URI after user authorization.
    #
    # @raise [ArgumentError] If neither `client_code` nor `code` is provided.
    #
    # @return [Hash] A hash containing the OAuth2 token response.
    #   The response typically includes:
    #   - `:access_token` [String] The access token to be used for API requests.
    #   - `:expires_in` [Integer] The token's expiration time in seconds.
    #   - `:refresh_token` [String] The refresh token for obtaining a new access token.
    #
    # @example Fetch token using client_code
    #   fetch_token(client_code: "123e4567-e89b-12d3-a456-426614174000")
    #
    # @example Fetch token using authorization code
    #   fetch_token(code: "AQABAAIAAAAGV_b3")
    #
    # This method is called _after_ the user has authorized the client via #authorize method with the browser.
    # `code` is used when #authorize method was called with redirect_uri. It is found in the redirect to your server.
    # `client_code` is used when no redirect_uri is provided for #authorize method. It is returned by #authorize method.
    def fetch_token(client_code: nil, code: nil)
      raise ArgumentError, "Either client_code or code must be provided" if client_code.nil? && code.nil?

      params = @client_params.clone
      if client_code
        params[:client_code] = client_code
        params[:grant_type] = "client_code"
      else
        params[:grant_type] = "authorization_code"
        params[:code] = code
      end

      response = Faraday.post(TOKEN_URL) do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form(params)
      end

      store_token(response)
    end

    def refresh_access_token
      return NotAuthorizedError unless @tokens && @tokens[:refresh_token]

      params = client_params.clone.merge({ grant_type: "refresh_token", refresh_token: @tokens[:refresh_token] })
      response = Faraday.post(TOKEN_URL) do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form(params)
      end

      store_token(response)
    end

    def valid_token?
      @tokens && @tokens[:access_token] && @tokens[:expires_at] && Time.now - 3600 < @tokens[:expires_at]
    end

    def refresh_token_if_needed
      return if valid_token?

      UkrsibAPI.logger.info "Refreshing expired token..."
      refresh_access_token
    end

    def generate_signature(data_string)
      signature = @private_key.sign(OpenSSL::Digest.new("SHA512"), data_string)
      Base64.strict_encode64(signature)
    end

    private

    def store_token(response)
      raise Error, "Authentication failed: #{response.status} - #{response.body}" unless response.status == 200

      body = JSON.parse(response.body)
      new_tokens = {
        access_token: body["access_token"],
        refresh_token: body["refresh_token"],
        expires_at: Time.now + body["expires_in"].to_i
      }
      @tokens = new_tokens

      UkrsibAPI.logger.info "New access token retrieved. Expires at: #{@tokens[:expires_at]}"
      new_tokens
    end
  end
end
