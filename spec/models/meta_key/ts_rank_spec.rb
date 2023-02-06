require 'spec_helper'
require 'spec_helper_no_tx'

describe MetaKey do
  it 'filter by term and ts_rank order' do
    mk1 = FactoryBot.create(
      :meta_key_text,
      id: 'test:term',
      labels: { de: 'term' })
    mk2 = FactoryBot.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(number: 10)}",
      labels: { de: 'term' },
      descriptions: { de: 'term' })
    mk3 = FactoryBot.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(number: 10)}",
      labels: { de: 'term' })
    mk4 = FactoryBot.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(number: 10)}",
      descriptions: { de: 'term' },
      hints: { de: 'term' })
    mk5 = FactoryBot.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(number: 10)}",
      descriptions: { de: 'term' })
    mk6 = FactoryBot.create(
      :meta_key_text,
      id: "text:#{Faker::Lorem.characters(number: 10)}",
      hints: { de: 'term' })
    FactoryBot.create(:meta_key_text)

    expect(MetaKey.filter_by('term').map(&:id))
      .to be == [mk1, mk2, mk3, mk4, mk5, mk6].map(&:id)
  end
end
