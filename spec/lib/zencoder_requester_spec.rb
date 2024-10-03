require 'spec_helper'

describe ZencoderRequester do
  let(:media_file) { create :media_file_for_movie }

  describe '.new' do
    it 'raises ArgumentError when 2nd attribute is not an array' do
      expect { ZencoderRequester.new(media_file, only_profiles: true) }
        .to raise_error(ArgumentError)
    end

    it 'does not raise any error when 2nd attribute is an array' do
      expect { ZencoderRequester.new(media_file, only_profiles: %w(foo bar)) }
        .not_to raise_error
    end
  end

  describe '#process' do
    context 'when some required setting is missing' do
      it 'raises error when Zencoder is not enabled' do
        allow(Settings).to receive(:zencoder_enabled).and_return(false)
        allow(File).to receive(:exist?).and_return(true)

        expect { ZencoderRequester.new(media_file).process }
          .to raise_error(
            'Zencoder is not enabled! Check your zencoder configuration!')
      end

      it 'raises error when api key is not set' do
        allow(File).to receive(:exist?).and_return(true)
        allow(Settings).to receive(:zencoder_enabled).and_return(true)
        allow(Zencoder).to receive(:api_key).and_return(nil)

        expect { ZencoderRequester.new(media_file).process }
          .to raise_error(
            'Zencoder API key is mandatory for submitting to Zencoder.com')
      end
    end

    context 'when all settings are correct' do
      let(:base_url) { 'http://test.madek.com' }
      let!(:zencoder_job) do
        create(:zencoder_job,
               media_file: media_file,
               state: 'new')
      end

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(Zencoder).to receive(:api_key).and_return('abcd1234')
        allow(Settings).to receive(:madek_external_base_url).and_return(base_url)
        allow(Settings).to receive(:zencoder_enabled).and_return(true)
        allow(Settings).to receive(:zencoder_test_mode).and_return(true)
        allow(Settings).to receive(:zencoder_video_output_formats) do
          {
            mkv: { format: 'mkv', width: 480, thumbnails: true },
            flv: { format: 'flv', width: 520 }
          }
        end
        allow(Settings).to receive(:zencoder_video_thumbnails_defaults) do
          { width: 320, format: 'png' }
        end
        allow(ZencoderJob).to receive(:create).and_return(zencoder_job)
      end

      subject { ZencoderRequester.new(media_file).process }

      context 'when response from zencoder.com is successful' do
        before do
          stub_request(:post, 'https://app.zencoder.com/api/v2/jobs')
            .with(headers: { 'Zencoder-Api-Key' => 'abcd1234' })
            .to_return(
              body: {
                id: '1234',
                outputs: [
                  {
                    id: '4321'
                  }
                ]
              }.to_json,
              status: 201
            )
        end

        it 'creates encoding job' do
          expect(Zencoder::Job).to receive(:create).with(
            input: 'http://test.madek.com/files/' \
              "#{media_file.id}?access_token=#{media_file.zencoder_jobs.first.access_token}",
            notifications: ['http://test.madek.com/zencoder_jobs/' \
                              "#{zencoder_job.id}/notification"],
            test: true,
            label: 'Default',
            quality: 4,
            speed: 2,
            width: 620,
            outputs: [
              {
                'format' => 'mkv',
                'width' => 480,
                'thumbnails' => true,
                label: 'mkv',
                filename: "#{media_file.id}.profile_mkv."
              },
              {
                'format' => 'flv',
                'width' => 520,
                label: 'flv',
                filename: "#{media_file.id}.profile_flv." }
            ]
          ).and_call_original

          subject

          expect(zencoder_job.state).to eq 'submitted'
          expect(zencoder_job.response)
            .to eq(%({"id"=>"1234", "outputs"=>[{"id"=>"4321"}]}))
        end
      end

      # failed job has response code >= 300
      context 'when encoding job failed' do
        before do
          stub_request(:post, 'https://app.zencoder.com/api/v2/jobs')
            .with(headers: { 'Zencoder-Api-Key' => 'abcd1234' })
            .to_return(status: 404)
        end

        it 'updates zencoder job state to "failed"' do
          subject

          expect(zencoder_job.state).to eq 'failed'
        end
      end
    end
  end
end
