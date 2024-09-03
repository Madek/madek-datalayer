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

      # NOTE: Query explain: For the list of wanted `profiles`,
      # return all `media_files` that are missing one or more of them
      # and don't have *any*any*any* pending `zencoder_job`.
      #
      # This is simplied (disregard *any* pending jobs), could also be
      # "where any of profiles in zencoder_job.conversion_profiles".
      [:audio, :video].each do |type|
        scope "with_missing_#{type}_conversions".to_sym, lambda { |profiles|
          where(media_type: type)
          .with_no_pending_jobs
          .where(<<-SQL)
            EXISTS (
              (SELECT unnest(ARRAY[#{profiles.sort.map { |s| "'#{s}'" }.join(',')}]::text[]))
                EXCEPT
                (SELECT unnest(found_file.conversion_profiles)
                FROM media_files AS found_file
                WHERE found_file.id = media_files.id)
            )
          SQL
        }
      end

      # NOTE: hacky workaround for missing OR
      scope :with_missing_conversions, lambda { |profiles|
        from(<<-SQL)
          (
            (#{with_missing_audio_conversions(profiles[:audio] || []).to_sql})
            UNION
            (#{with_missing_video_conversions(profiles[:video] || []).to_sql})
          ) AS media_files
        SQL
      }

      scope :with_no_pending_jobs, lambda {
        where(<<-SQL)
          NOT EXISTS (
            SELECT 1
            FROM zencoder_jobs
            WHERE zencoder_jobs.media_file_id = media_files.id
            AND zencoder_jobs.state = 'submitted'
          )
        SQL
      }

      scope :with_no_jobs_after, lambda { |timestamp|
        where(<<-SQL, timestamp)
          NOT EXISTS (
            SELECT 1
            FROM zencoder_jobs
            WHERE zencoder_jobs.media_file_id = media_files.id
            AND zencoder_jobs.created_at > ?
          )
        SQL
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
