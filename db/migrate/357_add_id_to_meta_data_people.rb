class AddIdToMetaDataPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :meta_data_people, :id, :uuid, default: 'gen_random_uuid()', primary_key: true
  end
end
