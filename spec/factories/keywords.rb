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
  end
end
