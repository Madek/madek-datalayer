require 'spec_helper'
require Rails.root.join('spec',
                        'models',
                        'media_entry',
                        'combined_filter_shared_context.rb')

describe MediaEntry do
  include_context 'meta data shared context'

  it 'combines filters properly' do
    20.times do
      create \
        [:media_entry_with_image_media_file,
         :media_entry_with_audio_media_file].sample,
        :fat
    end

    filtered_media_entries = \
      MediaEntry
        .filter_by(meta_data: meta_data_1,
                   media_files: media_files_1,
                   permissions: permissions_1)
        .filter_by(meta_data: meta_data_2,
                   media_files: media_files_2,
                   permissions: permissions_2)

    expect(filtered_media_entries.count).to be == 1
    expect(filtered_media_entries.first).to be == media_entry
  end
end
