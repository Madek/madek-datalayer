module Concerns
  module MetaData
    module FilterHelpers
      def self.with_type(meta_datum)
        if meta_datum[:type].blank?
          type = MetaKey.find(meta_datum[:key]).meta_datum_object_type
        end
        meta_datum.merge(type: type) { |key, val1, val2| val1 }
      end

      def self.validate_keys_for_primitive!(meta_datum)
        if meta_datum[:match].blank?
          raise "':match' must be provided for primitive meta datum!"
        end
      end
    end
  end
end
