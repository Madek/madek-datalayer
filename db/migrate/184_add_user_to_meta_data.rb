class AddUserToMetaData < ActiveRecord::Migration[4.2]
  def up
    # meta_data_people ########################################################
    add_column :meta_data_people, :created_by_id, :uuid, null: true
    add_foreign_key(:meta_data_people, :users,
                    column: :created_by_id,
                    name: 'meta-data-people_users_fkey')
    remove_index(:meta_data_people,
                 name: :index_meta_data_people_on_meta_datum_id_and_person_id)
    add_index(:meta_data_people,
              [:meta_datum_id, :person_id],
              name: :index_md_people_on_md_id_and_person_id,
              unique: true)

    # meta_data_groups ########################################################
    add_column :meta_data_groups, :created_by_id, :uuid, null: true
    add_foreign_key(:meta_data_groups, :users,
                    column: :created_by_id,
                    name: 'meta-data-groups_users_fkey')
    remove_index(:meta_data_groups,
                 name: :index_meta_data_institutional_groups)
    add_index(:meta_data_groups,
              [:meta_datum_id, :group_id],
              name: :index_md_groups_on_md_id_and_group_id,
              unique: true)

    # meta_data_licenses ########################################################
    add_column :meta_data_licenses, :created_by_id, :uuid, null: true
    add_foreign_key(:meta_data_licenses, :users,
                    column: :created_by_id,
                    name: 'meta-data-licenses_users_fkey')
    remove_index(:meta_data_licenses,
                 name: :index_meta_data_licenses_on_meta_datum_id_and_license_id)
    add_index(:meta_data_licenses,
              [:meta_datum_id, :license_id],
              name: :index_md_licenses_on_md_id_and_license_id,
              unique: true)

    # meta_data_users ########################################################
    add_column :meta_data_users, :created_by_id, :uuid, null: true
    add_foreign_key(:meta_data_users,
                    :users,
                    column: :created_by_id,
                    name: 'meta-data-users_users_fkey2')
    remove_index(:meta_data_users,
                 name: :index_meta_data_users_on_meta_datum_id_and_user_id)
    add_index(:meta_data_users,
              [:meta_datum_id, :user_id],
              name: :index_md_users_on_md_id_and_user_id,
              unique: true)

    # meta_data_keywords ######################################################
    change_column :meta_data_keywords, :user_id, :uuid, null: true
    rename_column :meta_data_keywords, :user_id, :created_by_id
    add_index(:meta_data_keywords,
              [:meta_datum_id, :keyword_id],
              name: :index_md_users_on_md_id_and_keyword_id,
              unique: true)

    # meta_data ###############################################################
    add_column :meta_data, :created_by_id, :uuid, null: true
    add_foreign_key(:meta_data,
                    :users,
                    column: :created_by_id,
                    name: 'meta-data_users_fkey')
  end

  def down
    # meta_data_people ########################################################
    remove_index(:meta_data_people,
                 name: :index_md_people_on_md_id_and_person_id)
    add_index(:meta_data_people,
              [:meta_datum_id, :person_id],
              name: :index_meta_data_people_on_meta_datum_id_and_person_id)
    remove_foreign_key :meta_data_people, name: 'meta-data-people_users_fkey'
    remove_column :meta_data_people, :created_by_id

    # meta_data_groups ########################################################
    remove_index(:meta_data_groups,
                 name: :index_md_groups_on_md_id_and_group_id)
    add_index(:meta_data_groups,
              [:meta_datum_id, :group_id],
              name: :index_meta_data_institutional_groups)
    remove_foreign_key :meta_data_groups, name: 'meta-data-groups_users_fkey'
    remove_column :meta_data_groups, :created_by_id

    # meta_data_licenses ########################################################
    remove_index(:meta_data_licenses,
                 name: :index_md_licenses_on_md_id_and_license_id)
    add_index(:meta_data_licenses,
              [:meta_datum_id, :license_id],
              name: :index_meta_data_licenses_on_meta_datum_id_and_license_id)
    remove_foreign_key :meta_data_licenses, name: 'meta-data-licenses_users_fkey'
    remove_column :meta_data_licenses, :created_by_id

    # meta_data_users ########################################################
    remove_index(:meta_data_users,
                 name: :index_md_users_on_md_id_and_user_id)
    add_index(:meta_data_users,
              [:meta_datum_id, :user_id],
              name: :index_meta_data_users_on_meta_datum_id_and_user_id)
    remove_foreign_key :meta_data_users, name: 'meta-data-users_users_fkey2'
    remove_column :meta_data_users, :created_by_id

    # meta_data_keywords ######################################################
    remove_index(:meta_data_keywords,
                 name: :index_md_users_on_md_id_and_keyword_id)
    change_column :meta_data_keywords, :created_by_id, :uuid, null: false
    rename_column :meta_data_keywords, :created_by_id, :user_id

    # meta_data ###############################################################
    remove_foreign_key :meta_data, :users
    remove_column :meta_data, :created_by_id
  end
end
