module Concerns
  module MediaFiles
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :with_id_or_uploader_id, lambda { |id|
          where(
            'media_files.id = :id OR media_files.uploader_id = :id',
            id: id
          )
        }
        scope :with_filename_like, lambda { |term|
          where('media_files.filename ILIKE ?', "%#{term}%")
        }
        scope :with_missing_conversions, lambda { |codecs|
          joins(:zencoder_jobs)
            .where(
              %(zencoder_jobs.created_at = ( \
                SELECT MAX(zencoder_jobs.created_at) FROM zencoder_jobs \
                WHERE zencoder_jobs.media_file_id = media_files.id) \
              )
            )
            .where(%(zencoder_jobs.state != 'submitted'))
            .where.not(media_files: { audio_codecs: "{#{codecs.sort.join(',')}}" })
            .where(media_files: { media_type: :audio })
        }
        scope :with_failed_conversions, lambda {
          joins(:zencoder_jobs)
            .where(
              %(zencoder_jobs.created_at = ( \
                SELECT MAX(zencoder_jobs.created_at) FROM zencoder_jobs \
                WHERE zencoder_jobs.media_file_id = media_files.id)
              )
            )
            .where(zencoder_jobs: { state: :failed })
            .group('media_files.id')
        }
      end
    end
  end
end
