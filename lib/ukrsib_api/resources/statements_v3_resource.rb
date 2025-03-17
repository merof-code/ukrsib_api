# frozen_string_literal: true
# typed: true

module UkrsibAPI
  module Resources
    ##
    # TransactionResource is responsible for fetching transaction data from the API.
    # It supports three endpoints:
    #
    # 1. Standard transactions endpoint (with a date interval).
    # 2. Interim transactions endpoint (for data from the last day up to today).
    # 3. Final transactions endpoint (for final transactions on the last day).
    #
    # Each endpoint is paginated. The methods in this class return an Enumerator that
    # lazily fetches and yields transactions page by page.
    class StatementsV3Resource < UkrsibAPI::Resource
      BASE_URI = "v3/statements"
      SIGN_FIELD_FORMULA = %i[accounts dateFrom dateTo firstResult maxResult].freeze

      def common(uri:, query_params:)
        UkrsibAPI::PaginationHelper
          .paginate(params_hash: query_params, key: "data", type: UkrsibAPI::Models::StatementV3) do |params|
          post_request(uri, body: params, sign_fields: SIGN_FIELD_FORMULA)
        end
      end

      def list(accounts:, date_from:, date_to:, first_result: 0, max_result: 100)
        query_params = form_query(
          date_from:, date_to:, accounts:, first_result:, max_result:
        )
        common(uri: BASE_URI, query_params: query_params)
      end
    end
  end
end
