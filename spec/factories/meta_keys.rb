FactoryGirl.define do

  factory :meta_key do

    vocabulary do
      vocabulary_id = id.split(':').first
      Vocabulary.find_by(id: vocabulary_id) \
        || FactoryGirl.create(:vocabulary, id: vocabulary_id)
    end

    is_enabled_for_media_entries true
    is_enabled_for_collections true
    is_enabled_for_filter_sets true

    labels do
      { AppSetting.default_locale => Faker::Lorem.characters(10) }
    end

    factory :meta_key_text, class: MetaKey do
      id { 'test:string' }
      meta_datum_object_type 'MetaDatum::Text'
    end

    factory :meta_key_json, class: MetaKey do
      id { 'test:json' }
      meta_datum_object_type 'MetaDatum::JSON'
    end

    factory :meta_key_text_date, class: MetaKey do
      id { 'test:datestring' }
      meta_datum_object_type 'MetaDatum::TextDate'
    end

    factory :meta_key_title, class: MetaKey do
      id { 'test:title' }
      meta_datum_object_type 'MetaDatum::Text'
    end

    factory :meta_key_keywords, class: MetaKey do
      id { 'test:keywords' }
      meta_datum_object_type 'MetaDatum::Keywords'
    end

    factory :meta_key_keywords_license, class: MetaKey do
      id { 'test:licenses' }
      allowed_rdf_class do
        RdfClass.find_by(id: 'License') || create(:rdf_class, id: 'License')
      end
      meta_datum_object_type 'MetaDatum::Keywords'
    end

    factory :meta_key_people, class: MetaKey do
      id { 'test:people' }
      meta_datum_object_type 'MetaDatum::People'
      allowed_people_subtypes %w(Person PeopleGroup)
    end

    factory :meta_key_people_instgroup, class: MetaKey do
      id { 'test:peopleinstgroup' }
      meta_datum_object_type 'MetaDatum::People'
      allowed_people_subtypes ['PeopleInstitutionalGroup']
    end

    factory :meta_key_roles, class: MetaKey do
      sequence(:id) { |n| "test:roles_#{n}" }
      meta_datum_object_type 'MetaDatum::Roles'
    end
  end

  factory :meta_key_core, class: MetaKey do

    vocabulary do
      Vocabulary.find_by(id: 'madek_core') \
        || FactoryGirl.create(:vocabulary, id: 'madek_core')
    end

    factory :meta_key_core_description, class: MetaKey do
      id 'madek_core:description'
      meta_datum_object_type 'MetaDatum::Text'
    end

    factory :meta_key_core_keywords, class: MetaKey do
      id 'madek_core:keywords'
      meta_datum_object_type 'MetaDatum::Keywords'
    end

    factory :meta_key_core_title, class: MetaKey do
      id 'madek_core:title'
      meta_datum_object_type 'MetaDatum::Text'
    end

  end

end
