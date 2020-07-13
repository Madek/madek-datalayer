FactoryGirl.define do

  VOCABULARY_ID = 'video_research_project'
  ANNOTATION_META_KEY_ID = 'video_research_project:annotation'

  class DummyResearchVideoFiles
  end

  factory :research_video_files, class: DummyResearchVideoFiles do
    skip_create

    before :create do
      Madek::System.execute_cmd! \
        "cp -r #{Madek::Constants::DATALAYER_ROOT_DIR.join(
          'spec', 'data', 'rv_files', 'originals', '*')} " \
         " #{Madek::Constants::FILE_STORAGE_DIR} "

      Madek::System.execute_cmd! \
        "cp -r #{Madek::Constants::DATALAYER_ROOT_DIR.join(
          'spec', 'data', 'rv_files', 'thumbnails', '*')} " \
         " #{Madek::Constants::THUMBNAIL_STORAGE_DIR} "
    end

  end

  factory :research_video_media_entry, parent: :media_entry do

    # TODO: remove the follwoing line
    responsible_user_id '653bf621-45c8-4a23-a15e-b29036aa9b10'

    get_full_size true
    get_metadata_and_previews true
    is_published true

    after :create do |me|
      mf = FactoryGirl.create :research_video_media_file, media_entry: me

      FactoryGirl.create :zencoder_job, media_file_id: mf.id, state: 'finished'

      Vocabulary.find_by(id: VOCABULARY_ID) ||
        FactoryGirl.create(:vocabulary,
                           id: VOCABULARY_ID,
                           enabled_for_public_view: true,
                           labels: { de: 'Research Video' })

      annotation_meta_key = MetaKey.find_by(id: ANNOTATION_META_KEY_ID) || \
         FactoryGirl.create(:meta_key,
                            id: ANNOTATION_META_KEY_ID,
                            is_enabled_for_media_entries: true,
                            meta_datum_object_type: 'MetaDatum::JSON',
                            labels: { de: 'Annotation' })

      context = Context.find_by(id: VOCABULARY_ID) ||
        FactoryGirl.create(:context, id: VOCABULARY_ID)

      ContextKey.find_by(context_id: context.id,
                         meta_key_id: annotation_meta_key.id) || \
         FactoryGirl.create(
           :context_key,
           context_id: context.id,
           meta_key_id: annotation_meta_key.id)

      FactoryGirl.create(
        :meta_datum_json,
        meta_key_id: annotation_meta_key.id,
        media_entry: me,
        json: JSON.load(Madek::Constants::DATALAYER_ROOT_DIR.join(
                          'spec', 'data', 'rv_files', 'annotations.json')))

    end
  end

  factory :research_video_media_file, parent: :media_file do

    before :create do
      FactoryGirl.create :research_video_files
    end

    association :media_entry, factory: :research_video_entry
    media_type 'video'
    media_entry_id 'f5b78e56-a229-4295-a4cc-0311e6534207'
    content_type 'video/mp4'
    size '11061375'
    width nil
    height nil
    access_hash '8d59e5b1-750a-4865-94fb-29c2c59453c9'
    conversion_profiles %w(mp4 webm)
    # id  'e563a508-094a-4fc3-83b3-b55ccbdfebb2'
    filename 'video.m4v'
    guid '8d9ad8d759094ed7a7dba75547b2c18d'
    extension 'm4v'

    after :create do |mf|

      previews_data = JSON.parse(
        <<-JSON.strip_heredoc
          [ {"id":"9e5c35bf-e27e-41fa-b0b4-4b437b7e3490","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":464,"width":620,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0000.jpg","thumbnail":"large","created_at":"2019-10-29T02:07:50.171414-07:00","updated_at":"2019-10-29T02:07:50.171414-07:00","media_type":"image","conversion_profile":null},
		        {"id":"b019868b-7ce4-4c5f-9b48-207b234e0f5b","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":null,"width":null,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0000_maximum.jpg","thumbnail":"maximum","created_at":"2019-10-29T02:07:50.943489-07:00","updated_at":"2019-10-29T02:07:50.943489-07:00","media_type":"image","conversion_profile":null},
		        {"id":"5f9b8bad-3428-4623-a401-53974a8fe7a5","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":768,"width":1024,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0000_x_large.jpg","thumbnail":"x_large","created_at":"2019-10-29T02:07:51.779195-07:00","updated_at":"2019-10-29T02:07:51.779195-07:00","media_type":"image","conversion_profile":null},
		        {"id":"f5150692-45a8-4467-919e-864d26b03636","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":300,"width":300,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0000_medium.jpg","thumbnail":"medium","created_at":"2019-10-29T02:07:52.472577-07:00","updated_at":"2019-10-29T02:07:52.472577-07:00","media_type":"image","conversion_profile":null},
		        {"id":"c79bfb47-6d9b-432a-aa9b-da846d4ddd90","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":125,"width":125,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0000_small_125.jpg","thumbnail":"small_125","created_at":"2019-10-29T02:07:53.170921-07:00","updated_at":"2019-10-29T02:07:53.170921-07:00","media_type":"image","conversion_profile":null},
		        {"id":"8026c2b4-28f9-4c94-b224-d91f5ee262e6","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":100,"width":100,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0000_small.jpg","thumbnail":"small","created_at":"2019-10-29T02:07:53.84393-07:00","updated_at":"2019-10-29T02:07:53.84393-07:00","media_type":"image","conversion_profile":null},
		        {"id":"b036a7ed-f2db-4624-b6dd-44e8203125f1","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":464,"width":620,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0001.jpg","thumbnail":"large","created_at":"2019-10-29T02:07:54.397218-07:00","updated_at":"2019-10-29T02:07:54.397218-07:00","media_type":"image","conversion_profile":null},
		        {"id":"a4663d4e-552f-48f7-9edd-9978c4ed88c6","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":null,"width":null,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0001_maximum.jpg","thumbnail":"maximum","created_at":"2019-10-29T02:07:55.084227-07:00","updated_at":"2019-10-29T02:07:55.084227-07:00","media_type":"image","conversion_profile":null},
		        {"id":"25b9f265-46cc-4f91-9363-d57fbe1fa4c4","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":768,"width":1024,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0001_x_large.jpg","thumbnail":"x_large","created_at":"2019-10-29T02:07:55.870582-07:00","updated_at":"2019-10-29T02:07:55.870582-07:00","media_type":"image","conversion_profile":null},
		        {"id":"04a06048-b454-416a-a054-ee7df971348e","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":300,"width":300,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0001_medium.jpg","thumbnail":"medium","created_at":"2019-10-29T02:07:56.620155-07:00","updated_at":"2019-10-29T02:07:56.620155-07:00","media_type":"image","conversion_profile":null},
		        {"id":"b1c4b4fe-3d02-47a3-8fe8-df9e1140700f","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":125,"width":125,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0001_small_125.jpg","thumbnail":"small_125","created_at":"2019-10-29T02:07:57.31085-07:00","updated_at":"2019-10-29T02:07:57.31085-07:00","media_type":"image","conversion_profile":null},
		        {"id":"dec0792f-1fe7-45e4-8b02-ed7d980d2e9d","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":100,"width":100,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0001_small.jpg","thumbnail":"small","created_at":"2019-10-29T02:07:58.019973-07:00","updated_at":"2019-10-29T02:07:58.019973-07:00","media_type":"image","conversion_profile":null},
		        {"id":"d741c76c-34c6-4728-a567-15d5994c855a","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":464,"width":620,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0002.jpg","thumbnail":"large","created_at":"2019-10-29T02:07:58.488999-07:00","updated_at":"2019-10-29T02:07:58.488999-07:00","media_type":"image","conversion_profile":null},
		        {"id":"8ac39ae3-064a-4595-8add-ed6c72289a57","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":null,"width":null,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0002_maximum.jpg","thumbnail":"maximum","created_at":"2019-10-29T02:07:59.208115-07:00","updated_at":"2019-10-29T02:07:59.208115-07:00","media_type":"image","conversion_profile":null},
		        {"id":"da63370e-f903-433f-aadd-9e0ae1bae0f5","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":768,"width":1024,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0002_x_large.jpg","thumbnail":"x_large","created_at":"2019-10-29T02:07:59.988905-07:00","updated_at":"2019-10-29T02:07:59.988905-07:00","media_type":"image","conversion_profile":null},
		        {"id":"2941fb6a-4c82-4c37-8471-46c192766776","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":300,"width":300,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0002_medium.jpg","thumbnail":"medium","created_at":"2019-10-29T02:08:00.784356-07:00","updated_at":"2019-10-29T02:08:00.784356-07:00","media_type":"image","conversion_profile":null},
		        {"id":"35b4e04e-52cc-4c55-9146-b26558f42d17","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":125,"width":125,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0002_small_125.jpg","thumbnail":"small_125","created_at":"2019-10-29T02:08:01.548111-07:00","updated_at":"2019-10-29T02:08:01.548111-07:00","media_type":"image","conversion_profile":null},
		        {"id":"654b732e-6415-4e63-8b18-bdd7e0ddb9e8","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":100,"width":100,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0002_small.jpg","thumbnail":"small","created_at":"2019-10-29T02:08:02.245098-07:00","updated_at":"2019-10-29T02:08:02.245098-07:00","media_type":"image","conversion_profile":null},
		        {"id":"fe48e6c4-d10f-4d75-9fc9-32bc14b168f7","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":464,"width":620,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0003.jpg","thumbnail":"large","created_at":"2019-10-29T02:08:02.749057-07:00","updated_at":"2019-10-29T02:08:02.749057-07:00","media_type":"image","conversion_profile":null},
		        {"id":"00bf2d24-19db-42b2-a9a3-ad9e3064a052","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":null,"width":null,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0003_maximum.jpg","thumbnail":"maximum","created_at":"2019-10-29T02:08:03.411196-07:00","updated_at":"2019-10-29T02:08:03.411196-07:00","media_type":"image","conversion_profile":null},
		        {"id":"605f58ea-2f73-4bbb-bd3f-4643613d57ee","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":768,"width":1024,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0003_x_large.jpg","thumbnail":"x_large","created_at":"2019-10-29T02:08:04.16595-07:00","updated_at":"2019-10-29T02:08:04.16595-07:00","media_type":"image","conversion_profile":null},
		        {"id":"b89ad1c5-fa05-4ab2-bdc6-4784c0525b87","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":300,"width":300,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0003_medium.jpg","thumbnail":"medium","created_at":"2019-10-29T02:08:04.882361-07:00","updated_at":"2019-10-29T02:08:04.882361-07:00","media_type":"image","conversion_profile":null},
		        {"id":"15fe6d65-e567-4ec8-976d-98a43464c881","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":125,"width":125,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0003_small_125.jpg","thumbnail":"small_125","created_at":"2019-10-29T02:08:05.607398-07:00","updated_at":"2019-10-29T02:08:05.607398-07:00","media_type":"image","conversion_profile":null},
		        {"id":"90903d5f-2781-431d-a75d-acf1611d7601","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":100,"width":100,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0003_small.jpg","thumbnail":"small","created_at":"2019-10-29T02:08:06.274181-07:00","updated_at":"2019-10-29T02:08:06.274181-07:00","media_type":"image","conversion_profile":null},
		        {"id":"1dccba40-8df8-4903-b47d-6b989e457de7","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":464,"width":620,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0004.jpg","thumbnail":"large","created_at":"2019-10-29T02:08:06.816111-07:00","updated_at":"2019-10-29T02:08:06.816111-07:00","media_type":"image","conversion_profile":null},
		        {"id":"52d85c74-b718-43b6-bc7d-9bb1bc480430","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":null,"width":null,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0004_maximum.jpg","thumbnail":"maximum","created_at":"2019-10-29T02:08:07.491683-07:00","updated_at":"2019-10-29T02:08:07.491683-07:00","media_type":"image","conversion_profile":null},
		        {"id":"4246c0b2-1dc1-4f90-84dc-3eb39f1d0cde","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":768,"width":1024,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0004_x_large.jpg","thumbnail":"x_large","created_at":"2019-10-29T02:08:08.202394-07:00","updated_at":"2019-10-29T02:08:08.202394-07:00","media_type":"image","conversion_profile":null},
		        {"id":"62361c95-c096-4880-ad2a-9c515deb4da7","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":300,"width":300,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0004_medium.jpg","thumbnail":"medium","created_at":"2019-10-29T02:08:08.982011-07:00","updated_at":"2019-10-29T02:08:08.982011-07:00","media_type":"image","conversion_profile":null},
		        {"id":"8f323c18-d745-483a-b56d-63e3fb883c58","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":125,"width":125,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0004_small_125.jpg","thumbnail":"small_125","created_at":"2019-10-29T02:08:09.708086-07:00","updated_at":"2019-10-29T02:08:09.708086-07:00","media_type":"image","conversion_profile":null},
		        {"id":"0110145f-49ba-48cd-b979-8bd5328d375c","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":100,"width":100,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0004_small.jpg","thumbnail":"small","created_at":"2019-10-29T02:08:10.360574-07:00","updated_at":"2019-10-29T02:08:10.360574-07:00","media_type":"image","conversion_profile":null},
		        {"id":"1ad9774c-84f3-4c0f-83cc-f6565fcb4ab0","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":464,"width":620,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0005.jpg","thumbnail":"large","created_at":"2019-10-29T02:08:10.874777-07:00","updated_at":"2019-10-29T02:08:10.874777-07:00","media_type":"image","conversion_profile":null},
		        {"id":"0a69709d-ebb0-4927-ba33-08ec7f724d24","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":null,"width":null,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0005_maximum.jpg","thumbnail":"maximum","created_at":"2019-10-29T02:08:11.568212-07:00","updated_at":"2019-10-29T02:08:11.568212-07:00","media_type":"image","conversion_profile":null},
		        {"id":"cae17667-27d7-4e1d-b579-63178b332962","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":768,"width":1024,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0005_x_large.jpg","thumbnail":"x_large","created_at":"2019-10-29T02:08:12.279618-07:00","updated_at":"2019-10-29T02:08:12.279618-07:00","media_type":"image","conversion_profile":null},
		        {"id":"feb5f373-d662-4770-97e1-f8409ab14a12","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":300,"width":300,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0005_medium.jpg","thumbnail":"medium","created_at":"2019-10-29T02:08:12.981229-07:00","updated_at":"2019-10-29T02:08:12.981229-07:00","media_type":"image","conversion_profile":null},
		        {"id":"134ed7a6-1d77-46f8-b486-8743856f71d6","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":125,"width":125,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0005_small_125.jpg","thumbnail":"small_125","created_at":"2019-10-29T02:08:13.691591-07:00","updated_at":"2019-10-29T02:08:13.691591-07:00","media_type":"image","conversion_profile":null},
		        {"id":"58227e3f-bbff-4819-a7c8-783414532079","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":100,"width":100,"content_type":"image/jpeg","filename":"8d9ad8d759094ed7a7dba75547b2c18d_0005_small.jpg","thumbnail":"small","created_at":"2019-10-29T02:08:14.401005-07:00","updated_at":"2019-10-29T02:08:14.401005-07:00","media_type":"image","conversion_profile":null},
		        {"id":"14a67a86-2c8c-4ecf-ab72-0c32a4034aa2","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":240,"width":320,"content_type":"video/mp4","filename":"8d9ad8d759094ed7a7dba75547b2c18d_320.mp4","thumbnail":"large","created_at":"2019-10-29T02:08:16.246893-07:00","updated_at":"2019-10-29T02:08:16.246893-07:00","media_type":"video","conversion_profile":"mp4"},
		        {"id":"b5f3a653-ef94-4861-a431-51cf48747d82","media_file_id":"e563a508-094a-4fc3-83b3-b55ccbdfebb2","height":240,"width":320,"content_type":"video/webm","filename":"8d9ad8d759094ed7a7dba75547b2c18d_320.webm","thumbnail":"large","created_at":"2019-10-29T02:08:18.067578-07:00","updated_at":"2019-10-29T02:08:18.067578-07:00","media_type":"video","conversion_profile":"webm"} ]
        JSON
      )

      previews_data.map do |pd|
        pd.with_indifferent_access
          .slice(:height, :width, :content_type, :media_type, :filename, :conversion_profile)
      end.each do |pd|
        Preview.create! pd.merge(media_file: mf)
      end
    end
  end
end
