require 'spec_helper'

describe Subtitle do
  let(:media_file) { FactoryBot.create(:media_file_for_movie) }
  let(:vtt) { "WEBVTT\n\n00:00:01.000 --> 00:00:02.000\nHallo\n" }

  def store(language:, is_default:, kind: 'subtitles', content: vtt)
    described_class.store!(
      media_file: media_file,
      language: language,
      kind: kind,
      label: language,
      filename: "#{language}.vtt",
      content: content,
      is_default: is_default
    )
  end

  it 'stores a WebVTT track on the media file' do
    subtitle = store(language: 'DE', is_default: true)

    expect(subtitle.language).to eq('de')
    expect(media_file.subtitles).to include(subtitle)
    expect(media_file.reload.media_config).to eq({})
  end

  it 'replaces the same language and keeps a single default track' do
    store(language: 'de', is_default: true)
    store(language: 'en', is_default: true)

    expect(media_file.subtitles.count).to eq(2)
    expect(media_file.subtitles.where(is_default: true).pluck(:language)).to eq(['en'])
  end

  it 'rejects content that is not WebVTT' do
    expect { store(language: 'de', is_default: false, content: 'hello') }
      .to raise_error(ActiveRecord::RecordInvalid)
  end
end
