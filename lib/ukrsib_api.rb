# typed: true
# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "dry-types"
require "dry-struct"
require "dry-transformer"
require "money"
require "securerandom"


require_relative "ukrsib_api/types"
require_relative "ukrsib_api/resource"
require_relative "ukrsib_api/request_id_middleware"
require_relative "ukrsib_api/authentication"
require_relative "ukrsib_api/client"
require_relative "ukrsib_api/base_transformer"
require_relative "ukrsib_api/models/base_struct"
require_relative "ukrsib_api/pagination_helper"

require_relative "ukrsib_api/resources/balance_resource"
require_relative "ukrsib_api/transformers/balance_transformer"
require_relative "ukrsib_api/models/balance"

require_relative "ukrsib_api/resources/statements_v3_resource"
require_relative "ukrsib_api/transformers/statement_v3_transformer"
require_relative "ukrsib_api/transformers/statement_party_details_transformer"
require_relative "ukrsib_api/models/statement_party_details"
require_relative "ukrsib_api/models/statement_v3"



# Main entry point for the gem, use client = UkrsibAPI::Client.new(api_token: "token") to start using the API.
module UkrsibAPI
  class Error < StandardError; end
  class NotAuthorizedError < Error; end

  def self.logger
    @@logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout, progname: "UkrsibAPI") # rubocop:disable Style/ClassVars
  end
end
