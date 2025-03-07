FactoryBot.define do
 factory :meta_datum_keyword, class: MetaDatum::Keyword do
    association :created_by, factory: :user
    keyword
    association :meta_datum, factory: :meta_datum_keywords
 end

 factory :meta_datum_role, class: MetaDatum::Role do
   meta_datum
   role
   person
   sequence :position
 end

 factory :meta_datum do
   created_by { create(:user) }

   before :create do |md|
     # we need app_setting for required context keys validation
     AppSetting.first.presence || create(:app_setting)

     unless md.media_entry or md.collection
       md.media_entry = FactoryBot.create(:media_entry, is_published: true)
     end
   end

   factory :meta_datum_text_date, class: MetaDatum::TextDate do
     string { Faker::Lorem.words.join(' ') }
     meta_key do
       MetaKey.find_by(id: attributes_for(:meta_key_text_date)[:id]) \
         || FactoryBot.create(:meta_key_text_date)
     end
   end

   factory :meta_datum_text, class: MetaDatum::Text do
     string { Faker::Lorem.words.join(' ') }
     meta_key do
       MetaKey.find_by(id: attributes_for(:meta_key_text)[:id]) \
         || FactoryBot.create(:meta_key_text)
     end

     factory :meta_datum_title do
       meta_key do
         MetaKey.find_by(id: 'madek_core:title') \
           || FactoryBot.create(:meta_key_text, id: 'madek_core:title')
       end

       factory :meta_datum_title_with_collection do
         collection { FactoryBot.create(:collection) }
       end

     end
   end

   factory :meta_datum_json, class: MetaDatum::JSON do
     json { { "some_boolean": true, "zero_point": -273.15, "seq": [1, 2, nil] } }
     meta_key do
       MetaKey.find_by(id: attributes_for(:meta_key_json)[:id]) \
         || FactoryBot.create(:meta_key_json)
     end
   end

   factory :meta_datum_media_entry, class: MetaDatum::MediaEntry do
     string { Faker::Lorem.sentence }
     other_media_entry { FactoryBot.create(:media_entry_with_title) }
     meta_key do
       MetaKey.find_by(id: 'test:media_entry') \
         || FactoryBot.create(:meta_key_media_entry)
     end
   end

   factory :meta_datum_keywords, class: MetaDatum::Keywords do
     meta_key do
       MetaKey.find_by(id: attributes_for(:meta_key_keywords)[:id]) \
         || FactoryBot.create(:meta_key_keywords)
     end
     keywords do
       (1..3).map do
         FactoryBot.create(:keyword,
                            meta_key_id: (meta_key_id or meta_key.id))
       end
     end
     after(:build) do |md|
       md.meta_data_keywords.map do |mdk|
         mdk.created_by = create(:user)
       end
     end
   end

   factory :meta_datum_people, class: MetaDatum::People do
     meta_key do
       MetaKey.find_by(id: attributes_for(:meta_key_people)[:id]) \
         || FactoryBot.create(:meta_key_people)
     end
     people { (1..3).map { FactoryBot.create :person } }
     after(:build) do |md|
       md.meta_data_people.map do |mdp|
         mdp.created_by = create(:user)
       end
     end
   end

   factory :meta_datum_roles, class: MetaDatum::Roles do
     meta_key do
       MetaKey.find_by(id: attributes_for(:meta_key_roles)[:id]) \
         || FactoryBot.create(:meta_key_roles)
     end
     transient do
       create_sample_data { true }
       people_with_roles { [] }
     end
     after(:create) do |md, evaluator|
       if evaluator.create_sample_data
         if evaluator.people_with_roles.blank?
           create_list :meta_datum_role, 3, meta_datum: md
           create :meta_datum_role, meta_datum: md, role: nil
         else
           evaluator.people_with_roles.each do |pwr|
             create(:meta_datum_role,
                    meta_datum: md,
                    person: pwr[:person],
                    role: pwr[:role])
           end
         end
       end
     end
   end
 end
end
