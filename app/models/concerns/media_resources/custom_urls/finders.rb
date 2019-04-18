module Concerns
  module MediaResources
    module CustomUrls
      module Finders
        extend ActiveSupport::Concern

        # NOTE: We extend the default `find` method with additional functionality
        # of getting the media_resource UUID via custom_urls and finding with that
        # UUID ***only*** if:
        # 1. no block was given
        # 2. the method call received a single argument
        # 3. the argument is a string
        # 4. the argument is not a UUID
        #
        # In all other cases we call the default `find` with given *args.
        #
        # Among others, this means that with UUID the method goes ALWAYS through
        # `collections.id = ?`, NEVER through `custom_urls.collection_id = ?`
        def find_with_custom_id(*args)
          if block_given?
            return find_without_custom_id(*args) do |*block_args|
              yield(*block_args)
            end
          end

          if args.length != 1
            return find_without_custom_id(*args)
          end

          arg = args.first

          unless arg.is_a?(String)
            return find_without_custom_id(arg)
          end

          if arg.match UUIDTools::UUID_REGEXP
            return find_without_custom_id(arg)
          end

          joins(:custom_urls).where(custom_urls: { id: arg }).take!
        end

        def find_by_id(arg)
          if arg.is_a?(String) and not arg.match UUIDTools::UUID_REGEXP
            # rubocop:disable Rails/FindBy
            joins(:custom_urls).where(custom_urls: { id: arg }).first
            # rubocop:enable Rails/FindBy
          else
            # rubocop:disable Rails/FindBy
            where(id: arg).first
            # rubocop:enable Rails/FindBy
          end
        end

        def prevent_find_by!
          raise NoMethodError,
                "this method is not supported for #{name} " \
                'or its ActiveRecord_Relation. ' \
                "See the documentation in app/models/#{model_name.singular}.rb"
        end

        def find_by(_ = nil)
          prevent_find_by!
        end

        def find_by!(_ = nil)
          prevent_find_by!
        end

        # for ActiveRecord_Relation
        included do
          alias_method :find_without_custom_id, :find
          alias_method :find, :find_with_custom_id
        end
      end
    end
  end
end
