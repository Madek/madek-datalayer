class DerivativeProfiles < ActiveRecord::Migration[5.2]

  class DerivativeProfile < ApplicationRecord
  end

  class MediaFile < ApplicationRecord
    has_many :previews, -> { order(:created_at, :id) }, dependent: :destroy
  end

  class Preview < ApplicationRecord
    belongs_to :media_file
  end

  def change

    cmt = <<-TXT.strip_heredoc
        Derivatives (previews) are generated based on matches
        on the content_type.
    TXT

    create_table :derivative_profiles,
      id: :text, primary_key: :label,
      comment: cmt do |t|
        t.text :content_type
        t.text :description
        t.jsonb :config
      end

      add_column :previews, :derivative_profile_id, :text
      add_foreign_key :previews, :derivative_profiles,
        column: :derivative_profile_id,
        primary_key: :label,
        on_delete: :nullify,
        on_update: :cascade

      reversible do |dir|
        dir.up do
          execute <<-SQL.strip_heredoc
          CREATE VIEW derivatives AS
            SELECT * FROM previews;
          SQL
        end
        dir.down do
          execute <<-SQL.strip_heredoc
          DROP VIEW derivatives;
          SQL
        end
      end

      reversible do |dir|
        dir.up do

          # create video profiles

          Settings.zencoder_video_output_formats.to_h.each do |k, v|
            puts "#{k} #{v}"
            DerivativeProfile.create! label: k, content_type: 'video',
              config: v.to_h
          end

          MediaFile.all.each do |mf|

            case mf.media_type

            when 'video'

              Preview.where(media_file_id: mf.id).each do |derivative|
                case derivative[:content_type]
                when /^video/
                  if cp = derivative[:conversion_profile]
                    derivative.update_attributes! derivative_profile_id: cp
                  else
                    case derivative[:content_type]
                    when 'video/webm'
                      derivative.update_attributes! derivative_profile_id: 'webm'
                    when 'video/mp4'
                      derivative.update_attributes! derivative_profile_id: 'mp4'
                    end
                  end
                else
                  puts "DERIVATIVE with content_type #{derivative[:content_type]} NOT HANDLED YET "
                end
              end

            else
              puts "MEDIA_FILE with type #{media_type} NOT HANDLED YET "
            end

          end

        end
      end
  end
end
