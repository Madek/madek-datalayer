module Concerns
  module MediaResources
    module PartOfWorkflow
      extend ActiveSupport::Concern

      class_methods do
        def parent_collections(resource_id)
          raise 'Not an UUID!' unless UUIDTools::UUID_REGEXP =~ resource_id

          relation = Collection.where("collections.id IN (#{parent_collections_query(resource_id)})")
          if self == Collection
            relation = relation.or(Collection.where(id: resource_id))
          end
          relation
        end

        def workflow_ids(resource_id)
          parent_collections(resource_id).joins(:workflow).pluck(:workflow_id)
        end

        private

        def parent_collections_query(resource_id)
          arcs_child_fk =
            case name
            when 'Collection'
              'child_id'
            when 'MediaEntry'
              'media_entry_id'
            end

          arcs_parent_fk =
            case name
            when 'Collection'
              'parent_id'
            when 'MediaEntry'
              'collection_id'
            end

          arcs_table_name = "collection_#{table_name.singularize}_arcs"

          <<-SQL.strip_heredoc
            WITH RECURSIVE parents as (
              SELECT parent_id
              FROM collection_collection_arcs
              WHERE child_id IN (
                SELECT #{arcs_parent_fk}
                FROM #{arcs_table_name}
                WHERE #{arcs_child_fk} = '#{resource_id}'
              )
              UNION
              SELECT cca.parent_id
              FROM collection_collection_arcs cca
              JOIN parents p ON cca.child_id = p.parent_id
            )
            SELECT parent_id FROM parents
            UNION
            SELECT cra.#{arcs_parent_fk}
            FROM #{arcs_table_name} cra
            WHERE #{arcs_child_fk} = '#{resource_id}'
          SQL
        end
      end

      def workflow
        (super rescue nil) || Workflow.find_by(id: self.class.workflow_ids(id))
      end

      def part_of_workflow?
        self.class.parent_collections(id).joins(:workflow).any?
      end
    end
  end
end
