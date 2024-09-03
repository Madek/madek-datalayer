module MediaResources
  module PartOfWorkflow
    extend ActiveSupport::Concern

    class_methods do
      def parent_collections(resource_id)
        raise 'Not an UUID!' unless valid_uuid?(resource_id)

        relation = Collection.where(
          "collections.id IN (#{parent_collections_query(resource_id)})")
        if self == Collection
          relation = relation.or(Collection.where(id: resource_id))
        end
        relation
      end

      def workflow_ids(resource_id)
        parent_collections(resource_id).joins(:workflow).pluck(:workflow_id)
      end

      private

      def arcs_child_fk
        case name
        when 'Collection'
          'child_id'
        when 'MediaEntry'
          'media_entry_id'
        end
      end

      def arcs_parent_fk
        case name
        when 'Collection'
          'parent_id'
        when 'MediaEntry'
          'collection_id'
        end
      end

      def arcs_table_name
        "collection_#{table_name.singularize}_arcs"
      end

      # rubocop:disable Metrics/MethodLength
      def parent_collections_query(resource_id = nil)
        raise 'Not an UUID!' if resource_id && !valid_uuid?(resource_id)

        id_or_fk = Arel.sql(resource_id ? "'#{resource_id}'" : "#{table_name}.id")
        <<-SQL.strip_heredoc
          WITH RECURSIVE parents as (
            SELECT parent_id
            FROM collection_collection_arcs
            WHERE child_id IN (
              SELECT #{arcs_parent_fk}
              FROM #{arcs_table_name}
              WHERE #{arcs_child_fk} = #{id_or_fk}
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
          WHERE #{arcs_child_fk} = #{id_or_fk}
        SQL
      end
    end
    # rubocop:enable Metrics/MethodLength

    def workflow
      (super rescue nil) || Workflow.find_by(id: self.class.workflow_ids(id))
    end

    def part_of_workflow?(active: nil)
      if [true, false].include?(active)
        parent_collections_with_workflows.where(workflows: { is_active: active }).any?
      else
        parent_collections_with_workflows.any?
      end
    end

    def parent_collections_with_workflows
      self.class.parent_collections(id).joins(:workflow)
    end
  end
end
