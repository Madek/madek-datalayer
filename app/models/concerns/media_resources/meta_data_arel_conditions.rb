module Concerns
  module MediaResources
    module MetaDataArelConditions
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Metrics/MethodLength
        def self.define_matching_meta_data_exists_conditition(match_table,
                                                              match_column)
          define_singleton_method \
            "matching_meta_data_#{match_table}_exists_conditition" do |match|
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
              .project(1)
              .where(
                Arel::Nodes::SqlLiteral.new \
                  "to_tsvector('english', #{match_table}.#{match_column}) @@ " \
                  "plainto_tsquery('english', '#{match}')")
              .where(meta_data_arel_table["#{model_name.singular}_id"]
                .eq arel_table[:id])
              .exists
          end
        end
        # rubocop:enable Metrics/MethodLength

        define_matching_meta_data_exists_conditition('keywords', 'term')
        define_matching_meta_data_exists_conditition('licenses', 'label')
        define_matching_meta_data_exists_conditition('people', 'searchable')
        define_matching_meta_data_exists_conditition('groups', 'searchable')

        def self.matching_meta_data_exists_condition(match)
          meta_data = MetaDatum.arel_table
          meta_data
            .project(1)
            .where(meta_data["#{model_name.singular}_id"].eq arel_table[:id])
            .where(Arel::Nodes::SqlLiteral.new \
                     "to_tsvector('english', meta_data.string) @@ " \
                     "plainto_tsquery('english', '#{match}')")
            .exists
        end
      end
    end
  end
end
