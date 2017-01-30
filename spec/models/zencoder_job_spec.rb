require 'spec_helper'

describe ZencoderJob do
  let(:media_file) { create :media_file_for_movie }
  let(:zencoder_job) do
    create :zencoder_job, media_file: media_file, zencoder_id: 4321
  end

  before do
    allow(Zencoder).to receive(:api_key).and_return('abc123')
    stub_request(:get, 'https://app.zencoder.com/api/v2/jobs/4321/progress')
      .with(headers: { 'Zencoder-Api-Key' => 'abc123' })
      .to_return(
        body: %({
          "state": "processing",
          "progress": 32.34567345,
          "input": {
            "id": 1234,
            "state": "finished"
          },
          "outputs": [
            {
              "id": 4567,
              "state": "processing",
              "current_event": "Transcoding",
              "current_event_progress": 25.0323,
              "progress": 35.23532
            },
            {
              "id": 4568,
              "state": "processing",
              "current_event": "Uploading",
              "current_event_progress": 82.32,
              "progress": 95.3223
            }
          ]
        })
      )
  end

  describe '#fetch_progress' do
    it 'returns actual job progress' do
      expect(zencoder_job.fetch_progress).to eq 32.34567345
    end

    it 'persists actual job progress' do
      expect { zencoder_job.fetch_progress }
        .to change { zencoder_job.progress }.from(0.0).to(32.34567345)
    end
  end
end
