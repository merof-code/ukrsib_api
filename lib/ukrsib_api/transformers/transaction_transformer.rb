# frozen_string_literal: true

module UkrsibAPI
  module Transformers
    # transaction field name mappings
    class TransactionTransformer < UkrsibAPI::BaseTransformer
      # Define the mapping for keys that need renaming
      # rubocop:disable Layout/HashAlignment
      KEY_MAPPING = {
        "AUT_MY_CRF"             => :recipient_code,
        "AUT_MY_MFO"             => :recipient_bank_code,
        "AUT_MY_ACC"             => :recipient_account,
        "AUT_MY_NAM"             => :recipient_name,
        "AUT_MY_MFO_NAME"        => :recipient_bank_name,
        "AUT_MY_MFO_CITY"        => :recipient_bank_city,
        "AUT_CNTR_CRF"           => :counterparty_code,
        "AUT_CNTR_MFO"           => :counterparty_bank_code,
        "AUT_CNTR_ACC"           => :counterparty_account,
        "AUT_CNTR_NAM"           => :counterparty_name,
        "AUT_CNTR_MFO_NAME"      => :counterparty_bank_name,
        "AUT_CNTR_MFO_CITY"      => :counterparty_bank_city,
        "CCY"                    => :currency,
        "FL_REAL"                => :real,
        "PR_PR"                  => :status,
        "DOC_TYP"                => :document_type,
        "NUM_DOC"                => :document_number,
        "DAT_KL"                 => :client_date,
        "DAT_OD"                 => :valuation_date,
        "OSND"                   => :reason,
        "SUM"                    => :amount,
        "SUM_E"                  => :amount_uah,
        "REF"                    => :reference,
        "REFN"                   => :reference_number,
        "TIM_P"                  => :valuation_time,
        "DATE_TIME_DAT_OD_TIM_P" => :valuation_date_time,
        "ID"                     => :id,
        "TRANTYPE"               => :transaction_type,
        "DLR"                    => :service_reference,
        "TECHNICAL_TRANSACTION_ID" => :technical_id
      }.freeze
      # rubocop:enable Layout/HashAlignment

      build_pipeline(KEY_MAPPING)
    end
  end
end
