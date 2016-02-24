FactoryGirl.define do

  factory :context do
    id { Faker::Internet.slug(nil, '-') }
    label { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    admin_comment { Faker::Lorem.sentence }

    factory :context_with_context_keys do
      transient do
        context_keys_count 3
      end

      after(:create) do |context, evaluator|
        create_list(:context_key,
                    evaluator.context_keys_count,
                    context: context)
      end
    end
  end

end
