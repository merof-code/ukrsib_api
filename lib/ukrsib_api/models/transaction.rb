# frozen_string_literal: true

module UkrsibAPI
  module Models
    # Transaction model
    #
    # It automatically defines two money helper methods:
    #  - amount_money: converts the 'amount' field to Money.
    #  - amount_uah_money: converts the 'amount_uah' field to Money using UAH.
    class Transaction < BaseStruct
      # ЄДРПОУ одержувача / Recipient code
      attribute :recipient_code, Types::String

      # МФО одержувача / Recipient bank code
      attribute :recipient_bank_code, Types::String

      # Рахунок одержувача / Recipient account
      attribute :recipient_account, Types::String

      # Назва одержувача / Recipient name
      attribute :recipient_name, Types::String

      # Банк одержувача / Recipient bank name
      attribute :recipient_bank_name, Types::String

      # Місто банку одержувача / Recipient bank city
      attribute :recipient_bank_city, Types::String

      # ЄДРПОУ контрагента / Counterparty code
      attribute :counterparty_code, Types::String

      # МФО контрагента / Counterparty bank code
      attribute :counterparty_bank_code, Types::String

      # Рахунок контрагента / Counterparty account
      attribute :counterparty_account, Types::String

      # Назва контрагента / Counterparty name
      attribute :counterparty_name, Types::String

      # Банк контрагента / Counterparty bank name
      attribute :counterparty_bank_name, Types::String

      # Місто банку контрагента / Counterparty bank city
      attribute :counterparty_bank_city, Types::String

      # Валюта / Currency
      attribute :currency, Types::String

      # Ознака реальності проведення (r,i) / Indicates if the transaction is real (r) or imaginary (i)
      attribute :real, Types::String

      # Стан транзакції: p - проводиться, t - сторнована, r - проведена, n - забракована
      # / Transaction status: p - processing, t - reversed, r - completed, n - rejected
      attribute :status, Types::String

      # Тип платіжного документа / Document type
      attribute :document_type, Types::String

      # Номер документа / Document number
      attribute :document_number, Types::String

      # Клієнтська дата (дд.мм.рррр) / Client date (dd.mm.yyyy)
      attribute :client_date, Types::Params::DateTime

      # Дата валютування (дд.мм.рррр) / Valuation date (dd.mm.yyyy)
      attribute :valuation_date, Types::Params::DateTime

      # Підстава платежу / Payment reason
      attribute :reason, Types::String

      # Сума / Amount
      attribute :amount, Types::Coercible::Decimal

      # Сума в національній валюті (грн) / Amount in UAH (national currency)
      attribute :amount_uah, Types::Coercible::Decimal

      # Референс проведення / Transaction reference
      attribute :reference, Types::String

      # Номер з/п всередині проведення / Internal sequence number within the transaction
      attribute :reference_number, Types::String

      # Час проведення (HH:MM) / Transaction time (HH:MM)
      attribute :valuation_time, Types::JSON::Time

      # Дата і час валютування (дд.мм.рррр HH:MM:SS) / Valuation date and time (dd.mm.yyyy HH:MM:SS)
      attribute :valuation_date_time, Types::Params::DateTime

      # ID транзакції / Transaction ID
      attribute :id, Types::String

      # Тип транзакції дебет/кредит (D, C) / Transaction type (debit/credit: D, C)
      attribute :transaction_type, Types::String

      # Референс платежу сервісу / Service payment reference
      attribute :service_reference, Types::String.optional

      # Технічний ідентифікатор транзакції / Technical transaction ID
      attribute :technical_id, Types::String

      MONEY_FIELDS = %i[
        amount amount_uah
      ].freeze

      MONEY_FIELDS.each do |field|
        define_method("#{field}_money") do
          currency_to_use = field.to_s.end_with?("_uah") ? "UAH" : currency
          Money.from_amount(public_send(field), currency_to_use)
        end
      end
    end
  end
end
