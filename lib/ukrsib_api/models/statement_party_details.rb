# frozen_string_literal: true

module UkrsibAPI
  module Models
    # PartyDetails model
    #
    # Represents details of a party, used for both actual payer and actual recipient.
    class StatementPartyDetails < BaseStruct
      # Номер квартиры / Apartment number
      attribute :apartment_number, Types::String.optional

      # Область / Area
      attribute :area, Types::String.optional

      # Город / City
      attribute :city, Types::String

      # Код страны (ISO 3166-1) / Country code
      attribute :country_code, Types::String

      # Номер дома / House number
      attribute :house_number, Types::String.optional

      # Почтовый индекс / Postcode
      attribute :postcode, Types::String.optional

      # Улица / Street
      attribute :street, Types::String

      # Детали юридического лица / Legal entity details
      attribute :legal_details, Types::Hash.optional
    end
  end
end
