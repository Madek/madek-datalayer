module Concerns
  module MediaResources
    module Filters
      module Filters
        extend ActiveSupport::Concern

        include Concerns::MediaResources::Filters::Helpers

        included do
          scope :filter_by_public_view, lambda { |bool|
            where(get_metadata_and_previews: bool)
          }
        end

        module ClassMethods
          def filter_by(**filter_opts)
            # NOTE: for the sake of sanity when analyzing the generated sql
            # and to prevent strange active record generation strategies, we
            # have to use "to_sql".
            # "unscoped" must be used in order to ensure proper chaining of
            # multiple filters
            scopes = [all]
            filter_opts.each do |key, value|
              scopes << unscoped.send("filter_by_#{key}", *value) if value
            end
            from \
              join_query_strings_with_intersect \
                *scopes.map(&:to_sql)
          end

          def filter_by_meta_data(*meta_data)
            unless meta_data.blank?
              query_strings = meta_data.map do |meta_datum|
                validate! meta_datum
                unscoped
                  .filter_by_meta_datum(meta_datum)
                  .to_sql
              end
              from \
                join_query_strings_with_intersect \
                  *query_strings
            else
              all
            end
          end

          def validate!(meta_datum)
            [:value, :match].each do |key_name|
              if meta_datum[key_name] and not meta_datum[key_name].is_a?(String)
                raise "#{key_name.capitalize} must be a string!"
              end
            end
          end

          def filter_by_media_files(*media_files)
            each_with_method_chain(:filter_by_media_file_helper,
                                   *media_files)
          end

          def filter_by_permissions(*permissions)
            each_with_method_chain(:filter_by_permission_helper,
                                   *permissions)
          end

          def each_with_method_chain(method, *key_values)
            result = all
            key_values.each do |key_value|
              result = \
                result.send(method,
                            key: key_value[:key],
                            value: key_value[:value])
            end
            result
          end

          def filter_by_media_file_helper(key: nil, value: nil)
            filter = joins(:media_file)
            unless value == 'any'
              filter = filter.where(media_files: Hash[key, value])
            end
            filter
          end

          def filter_by_permission_helper(key: nil, value: nil)
            case key
            when 'responsible_user'
              filter_by_responsible_user(value)
            when 'public'
              filter_by_public_view(value)
            when 'entrusted_to_group'
              entrusted_to_group Group.find(value)
            when 'entrusted_to_user'
              entrusted_to_user User.find(value)
            else
              raise 'Unrecognized permission key'
            end
          end
        end
      end
    end
  end
end
