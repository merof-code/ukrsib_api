# frozen_string_literal: true

# spec/ukrsib_api/client_spec.rb
require "spec_helper"

RSpec.describe UkrsibAPI::Client do
  describe "#api_key" do
    it "returns the correct API key" do
      client = UkrsibAPI::Client.new(api_key: "test")
      expect(client.api_key).to eq("test")
    end
  end
end
