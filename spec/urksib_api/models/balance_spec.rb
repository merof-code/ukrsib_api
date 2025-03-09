# frozen_string_literal: true

require "spec_helper"
RSpec.describe UkrsibAPI::Models::Balance do
  describe ".transformer" do
    it "returns a new instance of UkrsibAPI::Transformers::BalanceTransformer" do
      transformer = described_class.transformer
      expect(transformer).to be_an_instance_of(UkrsibAPI::Transformers::BalanceTransformer)
    end
  end
end
