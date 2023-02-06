require 'spec_helper'

# NOTE: creates very specific initial state - can't use factories!

describe MediaFile do

  PROFILE_TO_EXTENSION = { vorbis: 'ogg' }

  context 'Filters' do

    before do
      # ensure config
      Settings.zencoder_enabled = true
      Settings.zencoder_audio_output_formats = OpenStruct.new(
        mp3: { audio_codec: 'mp3', skip_video: true },
        vorbis: { audio_codec: 'vorbis', skip_video: true })
      Settings.zencoder_video_output_formats = OpenStruct.new(
        mp4: OpenStruct.new(
          video_codec: 'h264', format: 'mp4', width: 620, label: 'mp4'),
        webm: OpenStruct.new(
          format: 'webm', width: 620, label: 'webm',
          thumbnails: true, speed: 2, quality: 4))

      # cleanup
      ZencoderJob.destroy_all
      Preview.destroy_all
      MediaFile.destroy_all
    end

    example '.with_missing_conversions' do
      # expect initial state and config
      expect(Preview.count).to be 0
      expect(MediaFile.count).to be 0
      expect(Settings.zencoder_audio_output_formats.to_h.keys)
        .to match_array [:mp3, :vorbis]
      expect(Settings.zencoder_video_output_formats.to_h.keys)
        .to match_array [:mp4, :webm]

      # build scenario data
      start_time = Time.now.utc
      a1 = create_mf('audio/wav', file: '1.wav', profiles: [:vorbis])
      a2 = create_mf('audio/x-wav', file: '2.wav', profiles: [])
      a3 = create_mf('audio/mpeg', file: '3.mp3', profiles: [:mp3, :vorbis])
      create_mf('document/zip', file: '1.zip', profiles: [])
      v1 = create_mf('video/mov', file: '1.mov', profiles: [:mp4])
      _v2 = create_mf('video/avi', file: '2.avi', profiles: [:mp4, :webm])
      v3 = create_mf('video/m4v', file: '3.m4v', profiles: [])

      # sanity checks
      expect(Preview.count).to be 6
      expect(MediaFile.count).to be 7
      expect(a1.missing_profiles).to match_array [:mp3]
      expect(a2.missing_profiles).to match_array [:mp3, :vorbis]
      expect(a3.missing_profiles).to match_array []

      # filters/scopes initial
      expect(
        MediaFile.with_missing_conversions(audio: []).count).to eq 0
      expect(
        MediaFile.with_missing_conversions(audio: [:mp3]).count).to eq 2
      expect(
        MediaFile.with_missing_conversions(audio: [:vorbis]).count).to eq 1
      expect(
        MediaFile.with_missing_conversions(audio: [:mp3, :vorbis]).count).to eq 2

      expect(
        MediaFile.with_missing_conversions(video: [:mp4]).count).to eq 1
      expect(
        MediaFile.with_missing_conversions(video: [:webm]).count).to eq 2
      expect(
        MediaFile.with_missing_conversions(video: [:mp4, :webm]).count).to eq 2

      # filters/scopes while doing the batch
      ZencoderJob.create!(
        media_file: a1, state: 'submitted', conversion_profiles: [:mp3])
      ZencoderJob.create!(
        media_file: a2, state: 'failed', conversion_profiles: [:mp3])

      ZencoderJob.create!(
        media_file: v1, state: 'submitted', conversion_profiles: [:webm])

      expect(MediaFile.with_missing_conversions(audio: [:mp3]))
        .to match_array [a2]
      expect(MediaFile.with_missing_conversions(audio: [:vorbis]))
        .to match_array [a2]
      expect(MediaFile.with_missing_conversions(audio: [:mp3, :vorbis]))
        .to match_array [a2]

      expect(
        MediaFile.with_missing_conversions(audio: [:mp3])).to match_array [a2]
      expect(MediaFile.with_missing_conversions(audio: [:vorbis]))
        .to match_array [a2]
      expect(MediaFile.with_missing_conversions(audio: [:mp3, :vorbis]))
        .to match_array [a2]

      # if a job failed since we started the batch, ignore the files
      # (we don't want to double-sumbit files per batch)
      ZencoderJob.create!(
        media_file: v3, state: 'failed', conversion_profiles: [:mp4])

      expect(MediaFile
              .with_missing_conversions(video: [:mp4])
              .with_no_jobs_after(start_time)
            ).to be_empty
    end

  end
end

private

def create_mf(content_type, file:, profiles:)
  user = FactoryBot.create(:user)
  entry = FactoryBot.create(:media_entry, creator: user, responsible_user: user)
  type = content_type.split('/').first

  mf = MediaFile.create!(
    filename: file,
    extension: file.split('.').last,
    content_type: content_type,
    media_type: type,
    size: rand(1024 * 1024),
    media_entry: entry,
    uploader: user
  )
  simulate_postprocessing(mf, profiles)
  mf
end

def simulate_postprocessing(mf, profiles)
  return if profiles.empty?
  ZencoderJob.create!(
    media_file: mf, state: 'finished', conversion_profiles: profiles)
  profiles.each do |profile|
    ext = PROFILE_TO_EXTENSION.fetch(profile, profile)
    Preview.create!(
      media_file: mf,
      media_type: mf.media_type,
      conversion_profile: profile,
      content_type: "#{mf.media_type}/#{profile}",
      filename: "#{mf.filename.split('.').first}_preview.#{ext}"
    )
  end
end
