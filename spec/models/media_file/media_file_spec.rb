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
