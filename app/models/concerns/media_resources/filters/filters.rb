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
            if filter_opts.blank?
              all
            else
              filter_by_search(filter_opts[:search])
                .filter_by_meta_data(filter_opts[:meta_data])
                .filter_by_media_files(filter_opts[:media_files])
                .filter_by_permissions(filter_opts[:permissions])
                .uniq
            end
          end

          def filter_by_search(term)
            if term.blank?
              all
            else
              filter_by_meta_data [{ key: 'any', match: term }]
            end
          end

          def filter_by_meta_data(meta_data)
            if meta_data.blank?
              all
            else
              meta_data
                .map do |md, index|
                  md.merge md_alias: "md_#{SecureRandom.hex(4)}"
                end
                .reduce(all, :filter_by_meta_datum)
              # validate! meta_datum
            end
          end

          def validate!(meta_datum)
            [:value, :match].each do |key_name|
              if meta_datum[key_name] and not meta_datum[key_name].is_a?(String)
                raise "#{key_name.capitalize} must be a string!"
              end
            end
          end

          def filter_by_media_files(media_files)
            if media_files.blank?
              all
            else
              media_files.reduce(all, :filter_by_media_file_helper)
            end
          end

          def filter_by_permissions(permissions)
            if permissions.blank?
              all
            else
              permissions.reduce(all, :filter_by_permission_helper)
            end
          end

          def filter_by_media_file_helper(key: nil, value: nil)
            joins(:media_file).where(media_files: Hash[key, value])
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
