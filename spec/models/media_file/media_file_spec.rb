require 'spec_helper'

describe MediaFile do

  context 'Creation' do
    it 'should be producible by a factory' do
      expect { FactoryBot.create :media_file }.not_to raise_error
    end

    it 'validates presence of uploader' do
      expect { FactoryBot.create :media_file, uploader: nil }
        .to raise_error ActiveRecord::RecordInvalid
    end
  end

  context '.incomplete_encoded_videos' do
    it 'returns media files with no videos previews' do
      media_file = FactoryBot.create(:media_file_for_movie)
      image_preview = FactoryBot.create(:preview,
                                         content_type: 'image/jpeg',
                                         media_file: media_file)

      expect(media_file.previews).to include(image_preview)
      expect(image_preview.media_type).to be == 'image'
      expect(MediaFile.incomplete_encoded_videos).to include(media_file)
    end
  end

  describe '#create_previews!' do
    let(:image_media_file) do
      FactoryBot.create(:media_file, height: 1500, width: 2000)
    end
    let(:pdf_media_file) do
      FactoryBot.create(:media_file,
                        extension: 'pdf',
                        height: nil,
                        media_type: 'document',
                        width: nil)
    end

    before do
      allow(File).to receive(:exist?).and_call_original
      allow(FileConversion).to receive(:convert)

      stub_preview_conversion(image_media_file)
      stub_preview_conversion(pdf_media_file)
    end

    it 'generates all active thumbnail sizes for images' do
      image_media_file.create_previews!

      expect(image_media_file.previews.pluck(:thumbnail))
        .to match_array(Madek::Constants::THUMBNAILS.keys.map(&:to_s))
    end

    it 'skips sizes larger than the original' do
      media_file = FactoryBot.create(:media_file, height: 700, width: 1100)
      stub_preview_conversion(media_file)

      media_file.create_previews!

      expect(media_file.previews.pluck(:thumbnail))
        .to match_array(%w[maximum x_large large medium])
    end

    it 'generates sizes that downscale portrait images' do
      media_file = FactoryBot.create(:media_file, height: 1500, width: 1000)
      stub_preview_conversion(media_file)

      media_file.create_previews!

      expect(media_file.previews.pluck(:thumbnail))
        .to match_array(%w[maximum grand x_large large medium])
    end

    it 'skips sizes equal to the original' do
      media_file = FactoryBot.create(:media_file, height: 1024, width: 1024)
      stub_preview_conversion(media_file)

      media_file.create_previews!

      expect(media_file.previews.pluck(:thumbnail))
        .to match_array(%w[maximum large medium])
    end

    context 'with a video thumbnail' do
      let(:video_media_file) do
        FactoryBot.create(:media_file, height: nil, width: nil,
                                       content_type: 'video/mp4')
      end
      let(:video_thumbnail) { '/tmp/video_thumbnail_0000.jpg' }

      before do
        stub_preview_conversion(video_media_file)
        allow(File).to receive(:exist?).with(video_thumbnail).and_return(true)
      end

      it 'skips sizes not smaller than the thumbnail' do
        allow(video_media_file)
          .to receive(:get_dimensions)
          .with(video_thumbnail)
          .and_return(width: '1280', height: '720')

        video_media_file.create_previews!(video_thumbnail)

        expect(video_media_file.previews.pluck(:thumbnail))
          .to match_array(%w[maximum x_large medium])
      end

      it 'generates all sizes except large if thumbnail size is unknown' do
        allow(video_media_file)
          .to receive(:get_dimensions)
          .with(video_thumbnail)
          .and_return(nil)

        video_media_file.create_previews!(video_thumbnail)

        expect(video_media_file.previews.pluck(:thumbnail))
          .to match_array(%w[maximum x_grand grand x_large medium])
      end
    end

    it 'generates the requested thumbnail sizes' do
      thumbnail_profiles =
        Madek::Constants::THUMBNAILS.slice(:x_large, :large, :medium)

      pdf_media_file.create_previews!(thumbnail_profiles: thumbnail_profiles)

      expect(pdf_media_file.previews.pluck(:thumbnail))
        .to match_array(%w[x_large large medium])
    end
  end

  def stub_preview_conversion(media_file)
    allow(File)
      .to receive(:exist?)
      .with(media_file.original_store_location)
      .and_return(true)
    allow(media_file)
      .to receive(:get_dimensions)
      .and_return(width: 100, height: 100)
  end

end
