# frozen_string_literal: true

require "faraday"

module FaradayStubHelpers
  # Reads a fixture file from spec/fixtures and returns a stubbed response.
  def stub_response(fixture:, status: 200, headers: { "Content-Type" => "application/json" })
    fixture_path = File.join("spec", "fixtures", "#{fixture}.json")
    [status, headers, File.read(fixture_path)]
  end

  # Returns a Faraday test adapter stubs instance that responds to a specific path.
  def stub_request(path, response:, method: :get, body: {})
    Faraday::Adapter::Test::Stubs.new do |stub|
      arguments = [method, path]
      arguments << body.to_json if %i[post put patch].include?(method)
      stub.send(*arguments) { |_env| response }
    end
  end
end
