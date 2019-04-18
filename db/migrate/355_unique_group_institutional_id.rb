class UniqueGroupInstitutionalId < ActiveRecord::Migration[4.2]
  def up
    remove_index :groups, :institutional_group_id
    add_index :groups, :institutional_group_id, unique: true

    execute <<-SQL.strip_heredoc
      ALTER TABLE groups ADD CONSTRAINT check_valid_type CHECK
          (type IN ('AuthenticationGroup', 'InstitutionalGroup', 'Group'));
    SQL
  end

  def down
  end
end
