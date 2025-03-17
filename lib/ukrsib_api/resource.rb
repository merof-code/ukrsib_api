# frozen_string_literal: true
# typed: true

module UkrsibAPI
  # internal
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end

    ##
    # Builds the query parameters hash for API requests.
    #
    # This method generates a hash of query parameters based on the provided options.
    # It is designed to work with multiple endpoints:
    #
    # 1. **Date Interval Endpoints** (e.g., balances or transactions):
    #    - Requires :start_date (formatted as DD-MM-YYYY)
    #    - Optionally includes :end_date (formatted as DD-MM-YYYY)
    #    - :acc (account IBAN) is optional; if omitted, data for all active accounts are returned.
    #
    # 2. **Interim/Final Endpoints** (for getting partial or final data):
    #    - Date parameters are omitted.
    #    - Only :acc, :follow_id, and :limit are used.
    #
    # Additionally, if the API response contains:
    # - "exist_next_page" as true, then the "next_page_id" value should be passed in subsequent requests
    #   using the :follow_id parameter.
    #
    # @param start_date [Date, nil] the starting date (required for date interval endpoints)
    # @param end_date [Date, nil] the ending date (optional)
    # @param account [String, nil] the account number (IBAN); mapped to :acc in the query
    # @param follow_id [String, nil] identifier for the next page of results (pagination)
    # @param limit [Integer] number of records per page (default: 20, maximum recommended: 100)
    #
    # @return [Hash] the query parameters hash to be appended to the request URL
    def form_query(date_from:, date_to:, accounts:, first_result: 0, max_result: 100)
      params = {}
      # For date interval endpoints, only add date parameters if provided.
      params[:dateFrom] = date_from.to_time.to_i if date_from
      params[:dateTo]   = date_to.to_time.to_i if date_to
      # Account number is expected under the key :acc by the API.
      params[:accounts]       = accounts.join(',') if accounts.any?

      # Set limit for results per page.
      params[:firstResult] = first_result
      params[:maxResult] = max_result
      params
    end

    private

    def get_request(url, params: {}, headers: {})
      handle_response client.connection.get(url, params, headers)
    end

    def post_request(url, body:, headers: {}, sign_fields: [])
      sign_payload = sign_fields.map { |field| body[field] }.join("|")
      headers["Sign"] = @client.auth.generate_signature(sign_payload)
      handle_response client.connection.post(url, body, headers)
    end

    def handle_response(response)
      case response.status
      when 400
        raise Error, "Your request was malformed. #{response.body["message"]}"
      when 401
        raise Error, "You did not supply valid authentication credentials. #{response.body["message"]}"
      when 403
        raise Error, "You are not allowed to perform that action. #{response.body["message"]}"
      when 404
        raise Error, "No results were found for your request. #{response.body["message"]}"
      when 429
        raise Error, "Your request exceeded the API rate limit. #{response.body["message"]}"
      when 500
        raise Error, "We were unable to perform the request due to server-side problems. #{response.body["message"]}"
      else
        raise Error, response.body["message"] unless response.status == 200
      end

      response
    end
  end
end
