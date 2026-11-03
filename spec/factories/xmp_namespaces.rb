FactoryBot.define do

  factory :xmp_namespace do
    sequence(:prefix) { |n| "ns#{n}" }
    uri { "http://example.org/ns/#{prefix}/" }
  end

end
