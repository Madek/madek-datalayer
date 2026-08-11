FactoryBot.define do
  factory :admin do
    user

    after(:create) do |admin|
      AdminPermission::KEYS.each do |key|
        AdminPermission.create!(admin: admin, permission_key: key)
      end
    end
  end
end
