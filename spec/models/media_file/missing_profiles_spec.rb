require 'spec_helper'

describe MediaFile, '#missing_profiles' do
  let(:formats) do
    {
      mp4: { format: 'mp4' },
      hls: { type: 'playlist' },
      hls_360: { type: 'segmented', format: 'm4f' },
      hls_720: { type: 'segmented', format: 'm4f' },
      hls_1080: { type: 'segmented', format: 'm4f' }
    }
  end
  let(:media_file) do
    create(:media_file, media_type: 'video', content_type: 'video/mp4')
  end

  before do
    allow(Settings).to receive(:zencoder_video_output_formats).and_return(formats)
  end

  it 'treats every HLS rung as present once the master preview exists' do
    media_file.update_column(:conversion_profiles, %w[mp4 hls])

    expect(media_file.missing_profiles).to be_empty
  end

  it 'asks for the whole ladder when the master preview is absent' do
    media_file.update_column(:conversion_profiles, %w[mp4])

    expect(media_file.missing_profiles).to match_array(%i[hls hls_360 hls_720 hls_1080])
  end
end
