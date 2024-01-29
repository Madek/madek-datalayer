class AdjustPeopleDefaultSubtype < ActiveRecord::Migration[6.1]

  def change

    change_column :people, :subtype, :text, null: false, default: 'Person'

  end

end

