class CreateVisualization < ActiveRecord::Migration[4.2]

  def change
    create_table :visualizations, id: false do |t|
      t.primary_key :id, :uuid, default: 'gen_random_uuid()'
      t.uuid :user_id, null: false
      t.string :resource_identifier, null: false
      t.text :control_settings
      t.text :layout
    end

    add_foreign_key :visualizations, :users, dependent: :destroy
  end

end
