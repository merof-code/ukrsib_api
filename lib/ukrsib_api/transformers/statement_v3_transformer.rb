# frozen_string_literal: true

module UkrsibAPI
  module Transformers
    # Statement field name mappings
    class StatementV3Transformer < UkrsibAPI::BaseTransformer
      # Define the mapping for keys that need renaming
      # rubocop:disable Layout/HashAlignment
      KEY_MAPPING = {
        "clientBankName"         => :client_bank_name,
        "clientCode"             => :client_code,
        "clientIBAN"             => :client_iban,
        "correspondentBankMFO"   => :correspondent_bank_mfo,
        "correspondentBankName"  => :correspondent_bank_name,
        "correspondentCode"      => :correspondent_code,
        "correspondentIBAN"      => :correspondent_iban,
        "correspondentName"      => :correspondent_name,
        "credit"                 => :credit_amount,
        "currency"               => :currency,
        "dateValue"              => :valuation_date,
        "debit"                  => :debit_amount,
        "docDate"                => :document_date,
        "docNumber"              => :document_number,
        "paymentPurpose"         => :payment_purpose,
        "provDate"               => :processing_date,
        "reference"              => :reference,
        "actualPayer"            => :actual_payer,
        "actualRecipient"        => :actual_recipient,
        "budgetPaymentPurposes"  => :budget_payment_purposes
      }.freeze
      # rubocop:enable Layout/HashAlignment

      build_pipeline(KEY_MAPPING)
    end
  end
end
