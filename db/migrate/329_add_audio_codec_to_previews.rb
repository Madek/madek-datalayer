class AddAudioCodecToPreviews < ActiveRecord::Migration[4.2]
  class MigrationPreview < ActiveRecord::Base
    self.table_name = :previews

    belongs_to :media_file
  end

  def change
    add_column :previews, :audio_codec, :string

    reversible do |dir|
      dir.up do
        extension_codec = {
          'ogg' => 'vorbis',
          'mp3' => 'mp3',
          'mp4' => 'aac'
        }
        ActiveRecord::Base.transaction do
          MigrationPreview.where(media_type: :audio).find_each do |preview|
            if preview.audio_codec.blank?
              codec = extension_codec[File.extname(preview.filename)[1..-1]]
              preview.update_column(:audio_codec, codec) if codec.present?
            end
            preview.media_file.touch
          end
        end
      end
    end
  end
end
