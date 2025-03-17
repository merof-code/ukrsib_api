# frozen_string_literal: true

module UkrsibAPI::Models
  # best practices
  module Types
    include Dry.Types()

    UnixTimestampWithMilliseconds = Types::Coercible::Integer.constructor do |value|
      # Convert Unix timestamp (milliseconds) to Time object
      ::Time.at(value / 1000).utc if value
    end
    CoercibleDecimal = Types::Nominal::Decimal.constructor do |value|
      case value
      when Float
        BigDecimal(value.to_s, 2) # Convert float to string first
      else
        begin
          BigDecimal(value)
        rescue StandardError
          nil
        end # Fallback for other cases
      end
    end
  end
end
