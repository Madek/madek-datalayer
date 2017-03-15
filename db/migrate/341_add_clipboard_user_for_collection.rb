class AddClipboardUserForCollection < ActiveRecord::Migration
  def up
    add_column :collections, :clipboard_user_id, :string, null: true, default: nil
    add_index :collections, :clipboard_user_id, unique: true
  end
end
