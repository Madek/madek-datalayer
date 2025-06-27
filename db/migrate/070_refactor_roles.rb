class RefactorRoles < ActiveRecord::Migration[7.2]
  def up
    create_table :roles_lists, id: :uuid do |t|
      t.hstore :labels, null: false, default: {}
      t.timestamps null: false
    end

    add_column :meta_data_people, :role_id, :uuid, null: true
    add_foreign_key :meta_data_people, :roles, column: :role_id

    add_column :roles, :roles_list_id, :uuid, null: true
    add_foreign_key :roles, :roles_lists, column: :roles_list_id

    execute <<-SQL
      UPDATE meta_keys 
      SET meta_datum_object_type = 'MetaDatum::People'
      WHERE meta_datum_object_type = 'MetaDatum::Roles'
    SQL

    execute <<-SQL
      UPDATE meta_data 
      SET type = 'MetaDatum::People'
      WHERE type = 'MetaDatum::Roles'
    SQL

    remove_index :meta_data_people, name: "index_md_people_on_md_id_and_person_id"
    add_index(:meta_data_people,
              [:meta_datum_id, :person_id, :role_id],
              name: "index_md_people_on_md_id_person_id_and_role_id",
              unique: true)

    execute <<-SQL
      INSERT INTO meta_data_people (
        meta_datum_id,
        person_id,
        role_id,
        created_by_id,
        meta_data_updated_at,
        position
      )
      SELECT 
        mdr.meta_datum_id,
        mdr.person_id,
        mdr.role_id,
        md.created_by_id,
        NOW(),
        mdr.position
      FROM meta_data_roles mdr
      JOIN meta_data md ON md.id = mdr.meta_datum_id
      ON CONFLICT (meta_datum_id, person_id, role_id) DO NOTHING;
    SQL

    drop_table :meta_data_roles
  end
end
