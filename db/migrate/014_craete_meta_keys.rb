class CraeteMetaKeys < ActiveRecord::Migration[4.2]

  def change
    create_table :meta_keys, id: :string  do |t|

      t.boolean :is_extensible_list

      t.string :meta_datum_object_type, null: false, default: 'MetaDatumString'

      t.boolean :meta_terms_alphabetical_order, default: true

    end
  end
end
