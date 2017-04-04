module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Helpers
          extend ActiveSupport::Concern

          module ClassMethods
            # actors: person, keyword
            def filter_by_meta_datum_actor_type(actor_type, meta_datum)
              actor_type_plural = actor_type.to_s.pluralize
              rmd_alias = "md#{actor_type_plural.first}_#{SecureRandom.hex(4)}"

              joined_meta_data = \
                joins("INNER JOIN meta_data_#{actor_type_plural} #{rmd_alias} " \
                      "ON #{rmd_alias}.meta_datum_id " \
                      "= #{meta_datum[:md_alias] or 'meta_data'}.id")

              unless meta_datum[:value].blank?
                joined_meta_data
                  .joins("AND #{rmd_alias}.#{actor_type}_id = " \
                         "'#{meta_datum[:value]}'")
              else
                joined_meta_data
                  .joins("INNER JOIN #{actor_type_plural} " \
                         "ON #{rmd_alias}.#{actor_type}_id " \
                         "= #{actor_type_plural}.id " \
                         "AND to_tsvector('english', " \
                                         "#{actor_type_plural}.searchable) @@ " \
                         "plainto_tsquery('english', " \
                                         "'#{meta_datum[:match]}')")
              end
            end
          end
        end
      end
    end
  end
end
