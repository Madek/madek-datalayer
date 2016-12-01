class AddAudioCodecsToMediaFiles < ActiveRecord::Migration
  def change
    add_column :media_files, :audio_codecs, :string, array: true, default: []
  end
end
