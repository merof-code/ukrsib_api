# frozen_string_literal: true

module UkrsibAPI
  module Models
    # Statement model
    #
    # Represents a financial statement transaction.
    class StatementV3 < BaseStruct
      # Банк клиента / Client bank name
      attribute :client_bank_name, Types::String

      # ЄДРПОУ клиента / Client code
      attribute :client_code, Types::String

      # IBAN клиента / Client IBAN
      attribute :client_iban, Types::String

      # МФО банка корреспондента / Correspondent bank MFO
      attribute :correspondent_bank_mfo, Types::String

      # Название банка корреспондента / Correspondent bank name
      attribute :correspondent_bank_name, Types::String

      # ЄДРПОУ корреспондента / Correspondent code
      attribute :correspondent_code, Types::String

      # IBAN корреспондента / Correspondent IBAN
      attribute :correspondent_iban, Types::String

      # Название корреспондента / Correspondent name
      attribute :correspondent_name, Types::String

      # Сумма кредита / Credit amount
      attribute :credit_amount, Types::CoercibleDecimal

      # Валюта / Currency
      attribute :currency, Types::String

      # Дата валютирования / Valuation date
      attribute :valuation_date, Types::UnixTimestampWithMilliseconds.optional

      # Сумма дебета / Debit amount
      attribute :debit_amount, Types::CoercibleDecimal

      # Дата документа / Document date
      attribute :document_date, Types::UnixTimestampWithMilliseconds

      # Номер документа / Document number
      attribute :document_number, Types::String

      # Назначение платежа / Payment purpose
      attribute :payment_purpose, Types::String.optional

      # Дата обработки / Processing date
      attribute :processing_date, Types::UnixTimestampWithMilliseconds

      # Уникальный идентификатор транзакции / Transaction reference
      attribute :reference, Types::String

      # Фактический плательщик / Actual payer
      attribute :actual_payer, Types::Hash.optional

      # Фактический получатель / Actual recipient
      attribute :actual_recipient, Types::Hash.optional

      attribute :budget_payment_purposes, Types::Array.of(Types::Hash).optional
    end
  end
end
