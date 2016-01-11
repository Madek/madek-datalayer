module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Helpers
          extend ActiveSupport::Concern

          included do
            # actors: group, person, license, keyword
            scope \
              :filter_by_meta_datum_actor_type,
              lambda { |actor_type, column, meta_datum|
                actor_type_plural = actor_type.to_s.pluralize

                joined_meta_data = \
                  joins(:meta_data)
                    .joins("INNER JOIN meta_data_#{actor_type_plural} " \
                           "ON meta_data_#{actor_type_plural}.meta_datum_id " \
                           '= meta_data.id')

                unless meta_datum[:value].blank?
                  joined_meta_data
                    .where("meta_data_#{actor_type_plural}.#{actor_type}_id = ?",
                           meta_datum[:value])
                else
                  joined_meta_data
                    .joins("INNER JOIN #{actor_type_plural} " \
                           "ON meta_data_#{actor_type_plural}.#{actor_type}_id " \
                           "= #{actor_type_plural}.id")
                    .where("to_tsvector('english', " \
                                       "#{actor_type_plural}.#{column}) @@ " \
                           "plainto_tsquery('english', " \
                                           "'#{meta_datum[:match]}')")
                end
              }

            private_class_method :filter_by_meta_datum_actor_type
          end
        end
      end
    end
  end
end
