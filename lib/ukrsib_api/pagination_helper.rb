# frozen_string_literal: true

module UkrsibAPI
  # PaginationHelper provides pagination functionality by yielding individual items
  # from paginated HTTP responses.
  # @example
  # Example of usage:
  #   class BalanceResource < UkrsibAPI::Resource
  #     def common(uri, key, start_date, account, end_date)
  #       params_hash = form_query(start_date, account, end_date, nil, 20)
  #       # Pass a block to handle the HTTP request using your resource's get_request method.
  #       UkrsibAPI::PaginationHelper
  #         .load(uri: uri, params_hash: params_hash, key: "balances", type: UkrsibAPI::Models::Balance) do |uri, params|
  #         get_request(uri, params: params)
  #       end
  #     end
  #   end
  class PaginationHelper < Dry::Struct
    # @!attribute [r] data
    #   @return [Array] Array of transformed models.
    attribute :data, Types::Array.of(Types::Any)
    # @!attribute [r] next_page_exists
    #   @return [Boolean] Indicates if the next page exists.
    attribute :next_page_exists, Types::Bool
    # @!attribute [r] next_page_id
    #   @return [Any, nil] The identifier for the next page.
    attribute :next_page_start, Types::Any.optional

    # Loads paginated data and yields individual items.
    #
    # See example of usage in the class description.
    #
    # @param params_hash [Hash] Query parameters for the HTTP request.
    # @param key [String, Symbol] The key to extract data from the response body.
    # @param type [Class] A Dry::Struct model class used for transforming each item.
    # @yield [params] Must perform the HTTP request and return a response object.
    # @yieldreturn [Array] The HTTP response with a 'body' method containing a hash.
    # @return [Enumerator] An enumerator yielding individual items.
    def self.paginate(params_hash:, key:, type:)
      params_hash[:maxResult] ||= 100
      params_hash[:firstResult] ||= 0
      Enumerator.new do |yielder|
        loop do
          response = yield(params_hash)
          processed = from_response(response_body: response.body, key: key, type: type)
          processed.data.each { |item| yielder << item }
          break unless processed.next_page_exists && processed.next_page_id


          params_hash[:firstResult] = params_hash[:firstResult] + params_hash[:maxResult]
        end
      end
    end

    # Transforms the HTTP response and returns a new instance of PaginationHelper.
    #
    # @param response_body [Hash] The parsed HTTP response body.
    # @param key [String, Symbol] The key that holds the array of items.
    # @param type [Class] A Dry::Struct model class used to encapsulate each item.
    # @return [PaginationHelper] An instance containing the transformed data and pagination flags.
    def self.from_response(response_body:, key:, type:)
      body = response_body
      transformer = type.transformer
      transformed = transformer.call(body[key])
      new(
        data: transformed.map { |hash| type.new(hash) },
        next_page_exists: body["total"].to_i > (body["firstResult"].to_i + body["maxResult"].to_i),
        # TODO: possible bug, >= if it is all zero based
        next_page_start: body["firstResult"].to_i + body["maxResult"].to_i
      )
    end
  end
end
