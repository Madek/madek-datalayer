class DerivativeProfiles < ActiveRecord::Migration[5.2]

  class DerivativeProfile < ApplicationRecord
  end

  class Derivative < ApplicationRecord
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
          Settings.zencoder_video_output_formats.to_h.each do |k, v|
            puts "#{k} #{v}"
            DerivativeProfile.create! label: k, content_type: 'video',
              config: v.to_h
          end
          Derivative.all.each do |d|
            next if d[:content_type] =~ /^image/
            DerivativeProfile.all.each do |profile|
              # TODO WTF nothing matches; see the configuration on production
              if profile.config.try(:[],"width") == d.width
                binding.pry
              end
            end
          end
        end
      end
  end
end
