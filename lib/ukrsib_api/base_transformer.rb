# frozen_string_literal: true

module UkrsibAPI
  # transformer methods here
  class BaseTransformer < Dry::Transformer::Pipe
    import Dry::Transformer::HashTransformations
    import Dry::Transformer::ArrayTransformations

    # Build a transformation pipeline given a mapping
    def self.build_pipeline(mapping)
      define! do
        map_array do
          rename_keys(mapping)
          symbolize_keys
        end
      end
    end
  end
end
