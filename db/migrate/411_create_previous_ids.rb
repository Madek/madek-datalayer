class CreatePreviousIds < ActiveRecord::Migration[5.2]
  def change
    create_table :previous_person_ids, id: :uuid do |t|
      t.uuid :previous_id, null: false
      t.belongs_to :person, index: true, type: :uuid, null: false
    end
    add_index :previous_person_ids, :previous_id, unique: true

    create_table :previous_group_ids, id: :uuid do |t|
      t.uuid :previous_id, null: false
      t.belongs_to :group, index: true, type: :uuid, null: false
    end
    add_index :previous_group_ids, :previous_id, unique: true

    create_table :previous_keyword_ids, id: :uuid do |t|
      t.uuid :previous_id, null: false
      t.belongs_to :keyword, index: true, type: :uuid, null: false
    end
    add_index :previous_keyword_ids, :previous_id, unique: true
  end
end
