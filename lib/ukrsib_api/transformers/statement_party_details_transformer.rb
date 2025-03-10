# frozen_string_literal: true

module UkrsibAPI
  module Transformers
    # Transformer for party details (actual payer and recipient)
    # rubocop:disable Layout/HashAlignment
    class StatementPartyDetailsTransformer < UkrsibAPI::BaseTransformer
      KEY_MAPPING = {
        "addressApartmentNumber" => :apartment_number,
        "addressArea"            => :area,
        "addressCity"            => :city,
        "addressCountryCode"      => :country_code,
        "addressHouseNumber"      => :house_number,
        "addressPostcode"         => :postcode,
        "addressStreet"           => :street,
        "legal"                   => :legal_details
      }.freeze

      build_pipeline(KEY_MAPPING)
    end
    # rubocop:enable Layout/HashAlignment
  end
end
