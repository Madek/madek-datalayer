require 'spec_helper'
require 'spec_helper_no_tx'

describe MetaKey do
  it 'filter by term and ts_rank order' do
    mk1 = FactoryGirl.create(
      :meta_key_text,
      id: 'test:term',
      labels: { de: 'term' })
    mk2 = FactoryGirl.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(10)}",
      labels: { de: 'term' },
      descriptions: { de: 'term' })
    mk3 = FactoryGirl.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(10)}",
      labels: { de: 'term' })
    mk4 = FactoryGirl.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(10)}",
      descriptions: { de: 'term' },
      hints: { de: 'term' })
    mk5 = FactoryGirl.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(10)}",
      descriptions: { de: 'term' })
    mk6 = FactoryGirl.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(10)}",
      hints: { de: 'term' })
    FactoryGirl.create(:meta_key_text)

    expect(MetaKey.filter_by('term').map(&:id))
      .to be == [mk1, mk2, mk3, mk4, mk5, mk6].map(&:id)
  end
end
