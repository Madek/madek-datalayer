FactoryBot.define do

  factory :xmp_property do
    xmp_namespace
    sequence(:name) { |n| "Property#{n}" }
  end

end
