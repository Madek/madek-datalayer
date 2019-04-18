class AddConversionProfilesToZencoderJobs < ActiveRecord::Migration[4.2]
  class MigrationZencoderJob < ActiveRecord::Base
    self.table_name = :zencoder_jobs
  end

  def change
    add_column :zencoder_jobs, :conversion_profiles, :string, array: true, default: []

    reversible do |dir|
      dir.up do
        audio_outputs = Settings.zencoder_audio_output_formats.to_h
        video_outputs = Settings.zencoder_video_output_formats.to_h

        MigrationZencoderJob.find_each do |zj|
          if !zj.request.nil? && zj.request.present?
            begin
              request = YAML.load(zj.request.gsub(/:(\w+)=>/, '"\1":').gsub(/::(\w+)/, ':"\1"'))
            rescue => e
              puts e.message
              next
            end
            if request.kind_of?(Hash)
              found_profiles = []
              video_outputs.each_key do |profile|
                request.fetch('outputs', []).each do |output|
                  if output['format'] == profile.to_s
                    found_profiles << profile
                  end
                end
              end
              audio_outputs.each_key do |profile|
                request.fetch('outputs', []).each do |output|
                  if output['audio_codec'] == audio_outputs[profile].audio_codec
                    found_profiles << profile
                  end
                end
              end
              zj.update_column(:conversion_profiles, found_profiles.sort)
            end
          end
        end
      end
    end
  end
end
