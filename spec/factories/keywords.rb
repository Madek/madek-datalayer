FactoryGirl.define do
  factory :keyword do
    term do
      [Faker::Hipster.sentence.split(' ').sample,
       [Faker::Hacker.noun, Faker::Food.ingredient.split(' ').sample]
      ].flatten.shuffle.join('_').gsub(%r{[.,;\-/\\]}, '').classify
    end
    meta_key do
      MetaKey.find_by(id: 'test:keywords') \
               || FactoryGirl.create(:meta_key_keywords)
    end
    rdf_class do
      # is also the db default, but must be created if not exists
      RdfClass.find_by(id: 'Keyword') \
        || FactoryGirl.create(:rdf_class, id: 'Keyword')
    end

    trait :license do
      term { Faker::Lorem.words(3).join(' ') }
      meta_key do
        MetaKey.find_by(id: 'test:licenses') \
                 || FactoryGirl.create(:meta_key_keywords_license)
      end
      description do
        Faker::Hipster.sentence
      end
      external_uris do
        [Faker::Internet.url('example.com', "/licenses/#{SecureRandom.uuid}")]
      end
      rdf_class do
        RdfClass.find_by(id: 'License') \
          || FactoryGirl.create(:rdf_class, id: 'License')
      end
    end
  end

end
