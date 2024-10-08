module PreviousId
  extend ActiveSupport::Concern

  included do
    has_many :previous,
             nil,
             class_name: "::PreviousIds::Previous#{name}Id"
  end

  class_methods do
    def find_by_previous_id(id)
      find_by(id: find_current_id(id))
    end

    private

    def previous_id_class
      "PreviousIds::Previous#{name}Id".constantize
    end

    def find_current_id(id)
      mns = name.downcase

      # the recursive implementation is now unnecessary; it was either keep the
      # possibility to support chained merges and add code and complexity to
      # properly clean-up the database; or use simple fkeys which only work for
      # the case of one level depth; simple fkeys it is

      query = <<-SQL
        WITH RECURSIVE current_ids_tree as (
          SELECT #{mns}_id
          FROM previous_#{mns}_ids
          WHERE previous_id = ?
          UNION
          SELECT ppi.#{mns}_id
          FROM previous_#{mns}_ids ppi
          JOIN current_ids_tree tree ON tree.#{mns}_id = ppi.previous_id
        ) SELECT #{mns}_id FROM current_ids_tree
      SQL

      previous_id_class
        .find_by_sql([query, id])
        .pluck("#{mns}_id")
        .last
    end
  end

  def remember_id!(prev_id)
    previous.create!(previous_id: prev_id)
  end

  def remember_previous_ids!(receiver)
    previous_ids = previous.map(&:previous_id)
    previous.destroy_all
    previous_ids.push(id).each { |p_id| receiver.remember_id!(p_id) }
  end

  def previous_ids
    mns = model_name.singular

    # see comment about find_current_id

    query = <<-SQL
      WITH RECURSIVE previous_ids_tree as (
        SELECT previous_id
        FROM previous_#{mns}_ids
        WHERE #{mns}_id = '#{id}'
        UNION
        SELECT ppi.previous_id
        FROM previous_#{mns}_ids ppi
        JOIN previous_ids_tree tree ON tree.previous_id = ppi.#{mns}_id
      ) SELECT previous_id FROM previous_ids_tree
    SQL

    self
      .class
      .send(:previous_id_class)
      .find_by_sql(query)
      .pluck(:previous_id)
  end
end
