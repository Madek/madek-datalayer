FactoryGirl.define do
  factory :meta_datum_keyword, class: MetaDatum::Keyword do
    association :created_by, factory: :user
    keyword
    association :meta_datum, factory: :meta_datum_keywords
  end

  factory :meta_datum do
    created_by { create(:user) }

    after :build do |md|
      unless md.media_entry or md.collection or md.filter_set
        md.media_entry = FactoryGirl.create :media_entry
      end
    end

    factory :meta_datum_text_date, class: MetaDatum::TextDate do
      string { Faker::Lorem.words.join(' ') }
      meta_key do
        MetaKey.find_by(id: 'test:textdate') \
          || FactoryGirl.create(:meta_key_text_date)
      end
    end

    factory :meta_datum_text, class: MetaDatum::Text do
      string { Faker::Lorem.words.join(' ') }
      meta_key do
        MetaKey.find_by(id: 'test:text') \
          || FactoryGirl.create(:meta_key_text)
      end

      factory :meta_datum_title do
        meta_key do
          MetaKey.find_by(id: 'madek_core:title') \
            || FactoryGirl.create(:meta_key_text, id: 'madek_core:title')
        end

        factory :meta_datum_title_with_collection do
          collection { FactoryGirl.create(:collection) }
        end

        factory :meta_datum_title_with_filter_set do
          filter_set { FactoryGirl.create(:filter_set) }
        end
      end
    end

    factory :meta_datum_keywords, class: MetaDatum::Keywords do
      meta_key do
        MetaKey.find_by(id: 'test:keywords') \
          || FactoryGirl.create(:meta_key_text)
      end
      keywords { (1..3).map { FactoryGirl.create :keyword } }
      after(:build) do |md|
        md.meta_data_keywords.map do |mdk|
          mdk.created_by = create(:user)
        end
      end
    end

    factory :meta_datum_licenses, class: MetaDatum::Licenses do
      meta_key do
        MetaKey.find_by(id: 'test:licenses') \
          || FactoryGirl.create(:meta_key_licenses)
      end
      licenses { (1..3).map { FactoryGirl.create :license } }
      after(:build) do |md|
        md.meta_data_licenses.map do |mdl|
          mdl.created_by = create(:user)
        end
      end
    end

    factory :meta_datum_people, class: MetaDatum::People do
      meta_key do
        MetaKey.find_by(id: 'test:people') \
          || FactoryGirl.create(:meta_key_people)
      end
      people { (1..3).map { FactoryGirl.create :person } }
      after(:build) do |md|
        md.meta_data_people.map do |mdp|
          mdp.created_by = create(:user)
        end
      end
    end

    factory :meta_datum_groups, class: MetaDatum::Groups do
      meta_key do
        MetaKey.find_by(id: 'test:groups') \
          || FactoryGirl.create(:meta_key_groups)
      end
      groups { (1..3).map { create :group } }
      after(:build) do |md|
        md.meta_data_groups.map do |mdg|
          mdg.created_by = create(:user)
        end
      end
    end
  end
end
