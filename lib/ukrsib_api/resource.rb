# frozen_string_literal: true
# typed: true

module UkrsibAPI
  # internal
  class Resource
    DATE_FORMAT_STRING = "%d-%m-%Y"
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
    def form_query(start_date: nil, end_date: nil, account: nil, follow_id: nil, limit: 20)
      params = {}
      # For date interval endpoints, only add date parameters if provided.
      params[:startDate] = start_date.strftime(DATE_FORMAT_STRING) if start_date
      params[:endDate]   = end_date.strftime(DATE_FORMAT_STRING) if end_date
      # Account number is expected under the key :acc by the API.
      params[:acc]       = account if account
      # Pagination parameter.
      params[:followId]  = follow_id if follow_id
      # Set limit for results per page.
      params[:limit]     = limit
      params
    end

    private

    def get_request(url, params: {}, headers: {})
      handle_response client.connection.get(url, params, headers)
    end

    def post_request(url, body:, headers: {})
      handle_response client.connection.post(url, body, headers)
    end

    def patch_request(url, body:, headers: {})
      handle_response client.connection.patch(url, body, headers)
    end

    def put_request(url, body:, headers: {})
      handle_response client.connection.put(url, body, headers)
    end

    def delete_request(url, params: {}, headers: {})
      handle_response client.connection.delete(url, params, headers)
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
