# frozen_string_literal: true
# typed: true

module UkrsibAPI
  module Models
    # balance model, see api docs for more info (readme)
    class Balance < BaseStruct
      attribute :account,             Types::String
      attribute :currency,            Types::String
      attribute :counterparty_branch, Types::String
      attribute :account_branch,      Types::String
      attribute :account_name,        Types::String
      attribute :state,               Types::String
      attribute :account_type,        Types::String
      attribute :location,            Types::String

      # Decimal (monetary) attributes: using coercible decimals to convert string values
      attribute :balance_in,          Types::Coercible::Decimal
      attribute :balance_in_uah,      Types::Coercible::Decimal
      attribute :balance_out,         Types::Coercible::Decimal
      attribute :balance_out_uah,     Types::Coercible::Decimal
      attribute :turnover_debt,       Types::Coercible::Decimal
      attribute :turnover_debt_uah,   Types::Coercible::Decimal
      attribute :turnover_cred,       Types::Coercible::Decimal
      attribute :turnover_cred_uah,   Types::Coercible::Decimal

      # DateTime attributes: using Params coercion for strings formatted as dates
      attribute :last_operation_date_time, Types::Params::DateTime
      attribute :open_account_reg_date_time, Types::Params::DateTime
      attribute :open_account_sys_date_time, Types::Params::DateTime
      attribute :close_account_date_time,    Types::Params::DateTime

      # Boolean attribute
      attribute :final_balance, Types::Bool

      # @!method balance_in_money
      #   @return [Money] Returns a Money object for balance_in using the model's currency.
      #
      # @!method balance_in_uah_money
      #   @return [Money] Returns a Money object for balance_in_uah using "UAH" as currency.
      #
      # @!method balance_out_money
      #   @return [Money] Returns a Money object for balance_out using the model's currency.
      #
      # @!method balance_out_uah_money
      #   @return [Money] Returns a Money object for balance_out_uah using "UAH" as currency.
      #
      # @!method turnover_debt_money
      #   @return [Money] Returns a Money object for turnover_debt using the model's currency.
      #
      # @!method turnover_debt_uah_money
      #   @return [Money] Returns a Money object for turnover_debt_uah using "UAH" as currency.
      #
      # @!method turnover_cred_money
      #   @return [Money] Returns a Money object for turnover_cred using the model's currency.
      #
      # @!method turnover_cred_uah_money
      #   @return [Money] Returns a Money object for turnover_cred_uah using "UAH" as currency.

      # List of monetary attribute names.
      MONEY_FIELDS = %i[
        balance_in balance_in_uah
        balance_out balance_out_uah
        turnover_debt turnover_debt_uah
        turnover_cred turnover_cred_uah
      ].freeze

      # For each monetary field, define a method that returns a Money object.
      MONEY_FIELDS.each do |field|
        define_method("#{field}_money") do
          # Choose the currency based on the field name: if it ends with _uah, use "UAH",
          # otherwise use the model's currency.
          currency_to_use = field.to_s.end_with?("_uah") ? "UAH" : currency
          Money.from_amount(public_send(field), currency_to_use)
        end
      end
    end
  end
end
