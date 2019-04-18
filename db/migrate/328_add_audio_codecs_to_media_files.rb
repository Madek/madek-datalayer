class AddAudioCodecsToMediaFiles < ActiveRecord::Migration[4.2]
  def change
    add_column :media_files, :audio_codecs, :string, array: true, default: []
  end
end
