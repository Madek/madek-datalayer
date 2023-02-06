FactoryBot.define do

  factory :user do |n|
    person { FactoryBot.create :person }
    email do
      Faker::Internet.email.gsub('@',
                                 '_' + SecureRandom.uuid.first(8) + '@')
    end
    login { Faker::Internet.user_name + (SecureRandom.uuid.first 8) }
    accepted_usage_terms { UsageTerms.most_recent or create(:usage_terms) }
    password { SecureRandom.uuid }
    is_deactivated { false }
  end

  factory :admin_user, class: User do |n|
    person { FactoryBot.create :person }
    email do
      Faker::Internet.email.gsub('@',
                                 '_' + SecureRandom.uuid.first(8) + '@')
    end
    login { Faker::Internet.user_name + (SecureRandom.uuid.first 8) }
    accepted_usage_terms { UsageTerms.most_recent or create(:usage_terms) }
    password { SecureRandom.uuid }
    admin { FactoryBot.create :admin }
    is_deactivated { false }
  end

end
