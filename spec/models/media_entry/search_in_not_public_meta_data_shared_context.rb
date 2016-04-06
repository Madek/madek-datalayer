RSpec.shared_context 'meta data from not public vocabulary shared context' do
  let(:vocabulary) do
    FactoryGirl.create(:vocabulary, id: 'filter', enabled_for_public_view: false)
  end
  let(:responsible_user) { FactoryGirl.create(:user) }
  let(:meta_key) do
    FactoryGirl.create(:meta_key_text,
                       id: "#{vocabulary.id}:#{Faker::Lorem.characters(20)}",
                       vocabulary: vocabulary)
  end
  let (:media_entry) do
    media_entry = FactoryGirl.create(:media_entry_with_image_media_file,
                                     responsible_user: responsible_user)
    media_entry
  end

  # META DATA  ##########################################################
  let(:meta_datum_text) do
    meta_datum_text = FactoryGirl.create(:meta_datum_text,
                                         meta_key: meta_key,
                                         value: 'a par tial match')
    media_entry.meta_data << meta_datum_text
    meta_datum_text
  end
end
