FactoryGirl.define do

  class DummyEmbedTestFiles
  end

  factory :embed_test_files, class: DummyEmbedTestFiles do
    skip_create

    before :create do
      Madek::System.execute_cmd! \
        "cp -r #{Madek::Constants::DATALAYER_ROOT_DIR.join(
          'spec', 'data', 'embed_test_files', 'originals', '*')} " \
         " #{Madek::Constants::FILE_STORAGE_DIR} "

      Madek::System.execute_cmd! \
        "cp -r #{Madek::Constants::DATALAYER_ROOT_DIR.join(
          'spec', 'data', 'embed_test_files', 'thumbnails', '*')} " \
         " #{Madek::Constants::THUMBNAIL_STORAGE_DIR} "
    end

  end

  factory :embed_test_media_entry, parent: :media_entry do

    get_full_size true
    get_metadata_and_previews true
    is_published true

    after :create do |me|
      FactoryGirl.create(:meta_datum_text,
                         meta_key_id: 'madek_core:copyright_notice',
                         media_entry: me,
                         string: 'Public Domain')
      person = FactoryGirl.create(:person,
                                  first_name: 'Madek Team',
                                  last_name: nil,
                                  pseudonym: nil,
                                  subtype: 'PeopleGroup')
      FactoryGirl.create(:meta_datum_people,
                         meta_key_id: 'madek_core:authors',
                         media_entry: me,
                         people: [person])
    end

    factory :embed_test_video_entry do
      after :create do |me|
        mf = FactoryGirl.create :embed_test_video_file, media_entry: me
        FactoryGirl.create :zencoder_job, media_file_id: mf.id, state: 'finished'
        FactoryGirl.create :meta_datum_title, media_entry: me, string: 'madek-test-video'
      end
    end

    factory :embed_test_audio_entry do
      after :create do |me|
        mf = FactoryGirl.create :embed_test_audio_file, media_entry: me
        FactoryGirl.create :zencoder_job, media_file_id: mf.id, state: 'finished'
        FactoryGirl.create :meta_datum_title, media_entry: me, string: 'madek-test-audio'
      end
    end

    factory :embed_test_image_landscape_entry do
      after :create do |me|
        FactoryGirl.create :embed_test_image_landscape_file, media_entry: me
        FactoryGirl.create :meta_datum_title, media_entry: me, string: 'madek-test-image-landscape'
      end
    end

    factory :embed_test_image_portrait_entry do
      after :create do |me|
        FactoryGirl.create :embed_test_image_portrait_file, media_entry: me
        FactoryGirl.create :meta_datum_title, media_entry: me, string: 'madek-test-image-portrait'
      end
    end

  end

  factory :embed_test_media_file, parent: :media_file do

    before :create do
      FactoryGirl.create :embed_test_files
    end

    association :media_entry, factory: :embed_test_media_entries

    previews_json = nil

    after :create do |mf|
      previews_data = JSON.parse previews_json
      previews_data.map(&:with_indifferent_access).each do |pd|
        Preview.create! pd.merge(media_file: mf)
      end
    end

    factory :embed_test_video_file do
      before :create do
        previews_json = <<-JSON.strip_heredoc
          [ {"height":348,"width":620,"content_type":"image/jpeg","filename":"cb8c0a46f2744c3891ff5bd893581d21_0000.jpg","thumbnail":"large","media_type":"image","conversion_profile":null},
            {"height":null,"width":null,"content_type":"image/jpeg","filename":"cb8c0a46f2744c3891ff5bd893581d21_0000_maximum.jpg","thumbnail":"maximum","media_type":"image","conversion_profile":null},
            {"height":768,"width":1024,"content_type":"image/jpeg","filename":"cb8c0a46f2744c3891ff5bd893581d21_0000_x_large.jpg","thumbnail":"x_large","media_type":"image","conversion_profile":null},
            {"height":300,"width":300,"content_type":"image/jpeg","filename":"cb8c0a46f2744c3891ff5bd893581d21_0000_medium.jpg","thumbnail":"medium","media_type":"image","conversion_profile":null},
            {"height":125,"width":125,"content_type":"image/jpeg","filename":"cb8c0a46f2744c3891ff5bd893581d21_0000_small_125.jpg","thumbnail":"small_125","media_type":"image","conversion_profile":null},
            {"height":100,"width":100,"content_type":"image/jpeg","filename":"cb8c0a46f2744c3891ff5bd893581d21_0000_small.jpg","thumbnail":"small","media_type":"image","conversion_profile":null},
            {"height":348,"width":620,"content_type":"video/mp4","filename":"cb8c0a46f2744c3891ff5bd893581d21_620.mp4","thumbnail":"large","media_type":"video","conversion_profile":"mp4"},
            {"height":1080,"width":1920,"content_type":"video/webm","filename":"cb8c0a46f2744c3891ff5bd893581d21_1920.webm","thumbnail":"large","media_type":"video","conversion_profile":"webm_HD"},
            {"height":1080,"width":1920,"content_type":"video/mp4","filename":"cb8c0a46f2744c3891ff5bd893581d21_1920.mp4","thumbnail":"large","media_type":"video","conversion_profile":"mp4_HD"},
            {"height":348,"width":620,"content_type":"video/webm","filename":"cb8c0a46f2744c3891ff5bd893581d21_620.webm","thumbnail":"large","media_type":"video","conversion_profile":"webm"} ]
          JSON
      end

      media_type 'video'
      content_type 'video/mp4'
      size '1190633'
      width nil
      height nil
      access_hash '71aa02e6-cd0e-4ef1-abb5-886a7a965307'
      conversion_profiles %w(mp4 mp4_HD webm webm_HD)
      filename 'madek-test-video-5s.mp4'
      guid 'cb8c0a46f2744c3891ff5bd893581d21'
      extension 'mp4'
    end

    factory :embed_test_audio_file do
      before :create do
        previews_json = <<-JSON.strip_heredoc
        [ {"height":null,"width":null,"content_type":"audio/mpeg","filename":"137698174e13418cb5d8e960caaf3407.mp3","thumbnail":null,"media_type":"audio","conversion_profile":"mp3"},
          {"height":null,"width":null,"content_type":"audio/ogg","filename":"137698174e13418cb5d8e960caaf3407.ogg","thumbnail":null,"media_type":"audio","conversion_profile":"vorbis"} ]
        JSON
      end

      media_type 'audio'
      content_type 'audio/aac'
      size '1190633'
      width nil
      height nil
      access_hash 'b72edb2c-2e21-4c7e-ac7a-c625beff4b22'
      conversion_profiles %w(mp3 vorbis)
      filename 'test-audio.aac'
      guid '137698174e13418cb5d8e960caaf3407'
      extension 'aac'
    end

    factory :embed_test_image_landscape_file do
      before :create do
        previews_json = <<-JSON.strip_heredoc
        [ {"height":null,"width":null,"content_type":"image/jpeg","filename":"f7df90537cd547f2a82127229a52b452_maximum.jpg","thumbnail":"maximum","media_type":"image","conversion_profile":null},
          {"height":768,"width":1024,"content_type":"image/jpeg","filename":"f7df90537cd547f2a82127229a52b452_x_large.jpg","thumbnail":"x_large","media_type":"image","conversion_profile":null},
          {"height":500,"width":620,"content_type":"image/jpeg","filename":"f7df90537cd547f2a82127229a52b452_large.jpg","thumbnail":"large","media_type":"image","conversion_profile":null},
          {"height":300,"width":300,"content_type":"image/jpeg","filename":"f7df90537cd547f2a82127229a52b452_medium.jpg","thumbnail":"medium","media_type":"image","conversion_profile":null},
          {"height":125,"width":125,"content_type":"image/jpeg","filename":"f7df90537cd547f2a82127229a52b452_small_125.jpg","thumbnail":"small_125","media_type":"image","conversion_profile":null},
          {"height":100,"width":100,"content_type":"image/jpeg","filename":"f7df90537cd547f2a82127229a52b452_small.jpg","thumbnail":"small","media_type":"image","conversion_profile":null} ]
        JSON
      end

      media_type 'image'
      content_type 'image/tiff'
      size '318996'
      width nil
      height nil
      access_hash '36e3898a-8a27-4354-a758-e9f24fd287bb'
      conversion_profiles %w()
      filename 'test-image-wide.tif'
      guid 'f7df90537cd547f2a82127229a52b452'
      extension 'tif'
    end

    factory :embed_test_image_portrait_file do
      before :create do
        previews_json = <<-JSON.strip_heredoc
        [ {"height":null,"width":null,"content_type":"image/jpeg","filename":"16bb9f7f388e4b4eb4908f9d457718dc_maximum.jpg","thumbnail":"maximum","media_type":"image","conversion_profile":null},
          {"height":768,"width":1024,"content_type":"image/jpeg","filename":"16bb9f7f388e4b4eb4908f9d457718dc_x_large.jpg","thumbnail":"x_large","media_type":"image","conversion_profile":null},
          {"height":500,"width":620,"content_type":"image/jpeg","filename":"16bb9f7f388e4b4eb4908f9d457718dc_large.jpg","thumbnail":"large","media_type":"image","conversion_profile":null},
          {"height":300,"width":300,"content_type":"image/jpeg","filename":"16bb9f7f388e4b4eb4908f9d457718dc_medium.jpg","thumbnail":"medium","media_type":"image","conversion_profile":null},
          {"height":125,"width":125,"content_type":"image/jpeg","filename":"16bb9f7f388e4b4eb4908f9d457718dc_small_125.jpg","thumbnail":"small_125","media_type":"image","conversion_profile":null},
          {"height":100,"width":100,"content_type":"image/jpeg","filename":"16bb9f7f388e4b4eb4908f9d457718dc_small.jpg","thumbnail":"small","media_type":"image","conversion_profile":null} ]
        JSON
      end

      media_type 'image'
      content_type 'image/tiff'
      size '327516'
      width nil
      height nil
      access_hash '7674c885-3f6f-4c1c-ace1-33d4e21858d1'
      conversion_profiles %w()
      filename 'test-image-high.tif'
      guid '16bb9f7f388e4b4eb4908f9d457718dc'
      extension 'tif'
    end
  end
end
