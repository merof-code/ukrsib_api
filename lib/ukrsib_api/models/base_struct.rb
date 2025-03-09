# frozen_string_literal: true

module UkrsibAPI
  module Models
    # BaseStruct is a parent class for all models that require a transformer.
    # It dynamically infers the transformer class based on the name of the child class.
    #
    # Example:
    #   class Balance < BaseStruct; end
    #   Balance.transformer # Returns UkrsibAPI::Transformers::BalanceTransformer.new
    #
    #   class Transaction < BaseStruct; end
    #   Transaction.transformer # Returns UkrsibAPI::Transformers::TransactionTransformer.new
    #
    # This ensures that all subclasses of BaseStruct automatically have a transformer method
    # without needing to redefine it in each subclass.
    class BaseStruct < Dry::Struct
      # Returns an instance of the transformer class inferred from the child class name.
      # Example:
      #   class Balance < BaseStruct; end
      #   Balance.transformer # Returns UkrsibAPI::Transformers::BalanceTransformer.new
      def self.transformer
        short_name = name.split("::").last
        transformer_class_name = "#{short_name}Transformer"
        transformer_class = UkrsibAPI::Transformers.const_get(transformer_class_name)
        transformer_class.new
      end
    end
  end
end
