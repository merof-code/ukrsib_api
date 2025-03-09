# frozen_string_literal: true
# typed: true

module UkrsibAPI
  module Resources
    # see api docs
    class BalanceResource < UkrsibAPI::Resource
      def common(uri, _key, start_date, account, end_date)
        params_hash = form_query(start_date:, account:, end_date:)
        # Pass a block to handle the HTTP request using your resource's get_request method.

        UkrsibAPI::PaginationHelper
          .paginate(params_hash:, key: "balances", type: UkrsibAPI::Models::Balance) do |params|
            get_request(uri, params: params)
          end
      end

      # Get balance(s)
      # start_date required
      # account(iban string) and end_date optional
      def list(start_date, account = nil, end_date = nil)
        common("statements/balance", "balances", start_date, account, end_date)
      end

      # Get interim balance(s)
      #
      # @param start_date [String] the start date for the balance query (required)
      # @param account [String, nil] the account IBAN (optional)
      # @return [Array<UkrsibAPI::Models::Balance>] an array of Balance models
      def list_interim(start_date, account = nil, end_date = nil)
        common("statements/balance/interim", "balances", start_date, account, end_date)
      end

      # account = string iban, optional
      def list_final(account = nil)
        common("statements/balance/final", "balances", start_date, account, end_date)
      end
    end
  end
end
