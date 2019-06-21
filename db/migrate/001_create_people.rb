class CreatePeople < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  def change
    create_table :people, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.boolean :is_group, default: false
      t.date :date_of_birth
      t.date :date_of_death
      t.string :first_name
      t.string :last_name
      t.string :pseudonym
      t.text :searchable, null: false, default: ''

      t.timestamps null: false, default: 'now'
    end

    add_index :people, :first_name
    add_index :people, :last_name
    add_index :people, :is_group

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :people
        create_trgm_index :people, :searchable
        create_text_index :people, :searchable
      end
    end
  end

end
