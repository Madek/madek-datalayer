class AddDefaultContextIdToCollections < ActiveRecord::Migration[5.2]
  def change
    add_reference :collections,
                  :default_context,
                  type: :string,
                  foreign_key: { on_delete: :nullify, to_table: :contexts }
  end
end
