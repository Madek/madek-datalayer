class AddPositionToIoMappings < ActiveRecord::Migration[7.2]
  def up
    add_column :io_mappings, :position, :integer, null: false, default: 0

    execute <<-SQL.squish
      WITH ordered AS (
        SELECT id,
               (ROW_NUMBER() OVER (ORDER BY created_at ASC NULLS LAST, id ASC) - 1) AS pos
        FROM io_mappings
      )
      UPDATE io_mappings
      SET position = ordered.pos
      FROM ordered
      WHERE io_mappings.id = ordered.id
    SQL

    change_column_default :io_mappings, :position, from: 0, to: nil

    add_index :io_mappings, :position
  end

  def down
    remove_index :io_mappings, :position
    remove_column :io_mappings, :position
  end
end
