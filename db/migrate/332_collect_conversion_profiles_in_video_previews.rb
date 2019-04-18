class CollectConversionProfilesInVideoPreviews < ActiveRecord::Migration[4.2]
  class MigrationPreview < ActiveRecord::Base
    self.table_name = :previews

    belongs_to :media_file
  end

  class MigrationZencoderJob < ActiveRecord::Base
    self.table_name = :zencoder_jobs
  end

  def up
    video_outputs = Settings.zencoder_video_output_formats.to_h

    MigrationPreview.where(media_type: :video).find_each do |preview|
      video_outputs.each_key do |profile|
        if preview.content_type == "video/#{profile}"
          preview.update_column(:conversion_profile, profile)
          preview.media_file.touch
        end
      end
    end
  end
end
