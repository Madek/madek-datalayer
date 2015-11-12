FactoryGirl.define do
  factory :preview do
    height 348
    width 620
    content_type 'video/webm'
    filename do
      [
        Faker::Lorem.characters(24),
        content_type.split('/').last
      ]
        .join('.')
    end
    thumbnail { [:maximum, :x_large, :large, :medium, :small_125, :small].sample }
    media_type { content_type.split('/').first }
    association :media_file
  end
end
