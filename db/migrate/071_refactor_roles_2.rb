class RefactorRoles2 < ActiveRecord::Migration[7.2]
  def up
    # Add constraint after data migration to ensure roles_list_id is only set for MetaDatum::People
    execute <<-SQL
      ALTER TABLE meta_keys 
      ADD CONSTRAINT check_roles_list_id_only_for_people 
      CHECK (
        (meta_datum_object_type = 'MetaDatum::People') 
        OR 
        (meta_datum_object_type != 'MetaDatum::People' AND roles_list_id IS NULL)
      )
    SQL
  end
end
