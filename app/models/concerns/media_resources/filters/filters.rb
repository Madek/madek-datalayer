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
          # we need to supply the user information, because we need to scope
          # the meta_data by meta_keys/vocabularies a particular user is
          # allowed to see. In case of public, the user is nil per default.
          def filter_by(user = nil, **filter_opts)
            if filter_opts.blank?
              all
            else
              filter_by_search(filter_opts[:search])
                .filter_by_meta_data(user, filter_opts[:meta_data])
                .filter_by_media_files(filter_opts[:media_files])
                .filter_by_permissions(filter_opts[:permissions])
                .distinct
            end
          end

          def filter_by_search(term)
            if term.blank?
              all
            else
              filter_by_meta_data [{ key: 'any', match: term }]
            end
          end

          def filter_by_meta_data(user = nil, meta_data)
            if meta_data.blank?
              all
            else
              transformed_meta_data = \
                meta_data
                .map { |md| raise_if_not_viewable_meta_key_provided! md, user }
                .map { |md| add_scoped_meta_keys md, user }
                .map { |md| add_md_table_alias md }

              transformed_meta_data.reduce(all, :filter_by_meta_datum)
            end
          end

          def add_scoped_meta_keys(md, user)
            if md[:key] == 'any' or md[:not_key]
              md.merge meta_keys_scope: MetaKey.viewable_by_user_or_public(user)
            else
              md
            end
          end

          def add_md_table_alias(md)
            md.merge md_alias: "md_#{SecureRandom.hex(4)}"
          end

          def raise_if_not_viewable_meta_key_provided!(md, user)
            meta_key_id = (md[:key] or md[:not_key])
            if meta_key_id == 'any' \
                or MetaKey.find(meta_key_id).viewable_by_user_or_public?(user)
              md
            else
              raise "Not viewable meta_key leaked in: #{meta_key_id}!"
            end
          end

          # TODO: to we need this method?
          def validate_meta_datum!(meta_datum)
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
            if key == 'filename'
              joins(:media_file).where(
                'media_files.filename ILIKE :filename', filename: "%#{value}%")
            else
              joins(:media_file).where(
                media_files: Hash[key, value])
            end
          end

          def filter_by_permission_helper(key: nil, value: nil)
            # NOTE: Both public and visibility allow to filter for public
            # resources. The latter is newer and not in the API but used
            # in the side filter.
            case key
            when 'responsible_user'
              filter_by_responsible_user(value)
            when 'public'
              filter_by_public_view(value)
            when 'visibility'
              filter_by_permission_visibility(value)
            when 'entrusted_to_group'
              entrusted_to_group Group.find(value)
            when 'entrusted_to_user'
              entrusted_to_user User.find(value)
            else
              raise 'Unrecognized permission key'
            end
          end

          def filter_by_permission_visibility(value)
            case value
            when 'public'
              filter_by_visibility_public
            when 'user_or_group'
              filter_by_visibility_user_or_group
            when 'api'
              filter_by_visibility_api
            when 'private'
              filter_by_visibility_private
            else
              throw 'Unexpected visibility value: ' + value.to_s
            end
          end
        end
      end
    end
  end
end
