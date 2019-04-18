class UuidPkeyForIoMapping < ActiveRecord::Migration[4.2]
  def change
    add_column  :io_mappings, :id, :uuid, nil: false, default: 'gen_random_uuid()'
    execute "ALTER TABLE io_mappings DROP CONSTRAINT io_mappings_pkey;";
    add_index :io_mappings, :id, name: :io_mappings_pkey, unique: true
    execute "ALTER TABLE io_mappings ADD CONSTRAINT io_mappings_pkey PRIMARY KEY USING INDEX io_mappings_pkey; ";
  end
end
