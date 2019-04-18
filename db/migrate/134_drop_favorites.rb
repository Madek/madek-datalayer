class DropFavorites < ActiveRecord::Migration[4.2]

  def change
    drop_table :favorites
  end

end
