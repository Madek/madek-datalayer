module MetaKeys
  module MetaDatumObjectType
    module Keywords
      extend ActiveSupport::Concern

      included do
        #################################################################################
        # NOTE: order of statements is important here! ##################################
        #################################################################################
        # (1.)
        has_many :keywords

        # (2.) override one of the methods provided by (1.)
        def keywords
          ks = Keyword.where(meta_key_id: id)
          if keywords_alphabetical_order
            ks.order('keywords.term ASC')
          else
            ks.order('keywords.position ASC')
          end
        end
        #################################################################################

        scope :with_keywords_count, lambda {
          joins(
            'LEFT OUTER JOIN keywords ON keywords.meta_key_id = meta_keys.id'
          )
            .select('meta_keys.*, count(keywords.id) as keywords_count')
            .group('meta_keys.id')
        }

        before_save :keep_keywords_order_if_needed

        def can_have_keywords?
          meta_datum_object_type == 'MetaDatum::Keywords'
        end

        def can_have_allowed_rdf_class?
          meta_datum_object_type == 'MetaDatum::Keywords'
        end

        def media_entries_where_keywords_used_more_than_once
          if meta_datum_object_type == 'MetaDatum::Keywords'
            sql = <<~SQL
              SELECT meta_data.media_entry_id
              FROM meta_data
              JOIN meta_data_keywords ON meta_data_keywords.meta_datum_id = meta_data.id
              WHERE meta_data.meta_key_id = ?
                AND collection_id IS NULL
              GROUP BY media_entry_id
              HAVING count(*) > 1
            SQL

            MediaEntry.where(
              id: MetaDatum::Keywords.find_by_sql([sql, self.id]).map(&:media_entry_id)
            )
          end
        end

        def collections_where_keywords_used_more_than_once
          if meta_datum_object_type == 'MetaDatum::Keywords'
            sql = <<~SQL
              SELECT meta_data.collection_id
              FROM meta_data
              JOIN meta_data_keywords ON meta_data_keywords.meta_datum_id = meta_data.id
              WHERE meta_data.meta_key_id = ?
                AND media_entry_id IS NULL
              GROUP BY collection_id
              HAVING count(*) > 1
            SQL

            Collection.where(
              id: MetaDatum::Keywords.find_by_sql([sql, self.id]).map(&:collection_id)
            )
          end
        end

        private

        def keep_keywords_order_if_needed
          if keywords_alphabetical_order_changed? && !keywords_alphabetical_order
            unless keywords.empty?
              Keyword.transaction do
                keywords.reorder('term ASC').each_with_index do |keyword, index|
                  keyword.update_column :position, index
                end
              end
            end
          end
        end
      end
    end
  end
end
