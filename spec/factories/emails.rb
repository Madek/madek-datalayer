FactoryBot.define do

  factory :email do
    user
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    from_address { SmtpSetting.first.default_from_address }
    to_address { user.email }
  end

end
