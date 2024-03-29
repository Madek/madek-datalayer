FactoryBot.define do
  factory :preview do
    height { 348 }
    width { 620 }
    content_type { 'video/webm' }
    filename do
      [
        Faker::Lorem.characters(number: 24),
        content_type.split('/').last
      ]
        .join('.')
    end
    thumbnail { Madek::Constants::THUMBNAILS.keys.sample }
    media_type { content_type.split('/').first }
    association :media_file
  end
end
