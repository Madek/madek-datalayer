FactoryBot.define do

  factory :xmp_sidecar do
    association :media_entry
    association :user
    filename { 'sidecar.xmp' }
    meta_data { { 'XMP-dc:Title' => 'Title' } }
    xml { '<x:xmpmeta xmlns:x="adobe:ns:meta/"/>' }
  end

end
