class AddChecksumToMediaFiles < ActiveRecord::Migration[7.2]
  def change
    add_column :media_files, :checksum, :string, default: nil
    add_column :media_files, :checksum_verified_at, :timestamptz, default: nil
  end
end
