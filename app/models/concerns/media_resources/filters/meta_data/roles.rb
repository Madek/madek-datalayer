module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Roles
          extend ActiveSupport::Concern

          included do
            scope :filter_by_meta_datum_roles, lambda { |meta_datum|
              mdr_alias = "mdr_#{SecureRandom.hex(4)}"
              roles_alias = "roles_#{SecureRandom.hex(4)}"
              people_alias = "people_#{SecureRandom.hex(4)}"
              md_table_name = meta_datum[:md_alias] or 'meta_data'

              joined_meta_data = \
                joins("INNER JOIN meta_data_roles #{mdr_alias} " \
                      "ON #{mdr_alias}.meta_datum_id = #{md_table_name}.id") \
                  .joins("INNER JOIN people #{people_alias} " \
                         "ON #{people_alias}.id = #{mdr_alias}.person_id")
                  .joins("LEFT OUTER JOIN roles #{roles_alias} " \
                         "ON #{roles_alias}.id = #{mdr_alias}.role_id")

              unless meta_datum[:value].blank?
                joined_meta_data
                  .where("#{roles_alias}.id = :id OR #{people_alias}.id = :id",
                         id: meta_datum[:value])
              else
                joined_meta_data
              end
            }
          end
        end
      end
    end
  end
end
