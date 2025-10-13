module MediaResources
  module MetaDataArelConditions
    extend ActiveSupport::Concern

    included do
      # rubocop:disable Metrics/MethodLength
      def self.define_matching_meta_data_subquery(match_table,
                                                  match_column)
        define_singleton_method \
          "matching_meta_data_#{match_table}_subquery" \
          do |match, meta_key_ids|
          match_arel_table = Arel::Table.new(match_table)
          related_meta_data_arel_table = \
            Arel::Table.new("meta_data_#{match_table}")
          meta_data_arel_table = MetaDatum.arel_table

          match_arel_table
            .join(related_meta_data_arel_table)
            .on(match_arel_table[:id]
              .eq(related_meta_data_arel_table["#{match_table.singularize}_id"]))
            .join(meta_data_arel_table)
            .on(related_meta_data_arel_table[:meta_datum_id]
              .eq(meta_data_arel_table[:id]))
            .project("#{model_name.singular}_id")
            .where(
              Arel::Nodes::SqlLiteral.new(
                sanitize_sql_for_conditions(
                  [
                    'to_tsvector(' \
                    "'english', #{match_table}.#{match_column}" \
                    ') @@ ' \
                    "plainto_tsquery('english', '%s')",
                    match
                  ]
                )
              )
            )
            .where(meta_data_arel_table[:meta_key_id].in(meta_key_ids))
        end
      end
      # rubocop:enable Metrics/MethodLength

      define_matching_meta_data_subquery('keywords', 'term')
      define_matching_meta_data_subquery('people', 'searchable')

      def self.matching_meta_data_text_subquery(match, meta_key_ids)
        meta_data = MetaDatum.arel_table
        meta_data
          .project("#{model_name.singular}_id")
          .where(
            Arel::Nodes::SqlLiteral.new(
              sanitize_sql_for_conditions(
                multiple_ilike_helper(match)
              )
            )
          )
          .where(meta_data[:meta_key_id].in(meta_key_ids))
      end

      def self.multiple_ilike_helper(match)
        substrings = match.split(' ').map { |s| "%#{s}%" }
        where_clause = \
          Array
          .new(substrings.length, 'meta_data.string ILIKE ?')
          .join(' AND ')
        [where_clause, *substrings]
      end
    end
  end
end
