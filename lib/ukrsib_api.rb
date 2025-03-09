# typed: true
# frozen_string_literal: true

require "faraday"
require "faraday_middleware"
require "dry-types"
require "dry-struct"
require "dry-transformer"
require "money"

require_relative "ukrsib_api/version"
require_relative "ukrsib_api/types"
require_relative "ukrsib_api/client"
require_relative "ukrsib_api/resource"
require_relative "ukrsib_api/base_transformer"
require_relative "ukrsib_api/models/base_struct"

require_relative "ukrsib_api/resources/balance_resource"
require_relative "ukrsib_api/transformers/balance_transformer"
require_relative "ukrsib_api/models/balance"

require_relative "ukrsib_api/resources/transaction_resource"
require_relative "ukrsib_api/transformers/transaction_transformer"
require_relative "ukrsib_api/models/transaction"
require_relative "ukrsib_api/pagination_helper"

# Main entry point for the gem, use client = UkrsibAPI::Client.new(api_token: "token") to start using the API.
module UkrsibAPI
  class Error < StandardError; end

  def self.logger
    @@logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout, progname: "UkrsibAPI") # rubocop:disable Style/ClassVars
  end
end
