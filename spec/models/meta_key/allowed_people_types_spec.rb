require 'spec_helper'
require 'spec_helper_no_tx'

describe "allowed people subtypes for type 'MetaDatum::People'" do

  it 'raises if no value provided' do
    expect do
      FactoryBot.create(:meta_key_people, allowed_people_subtypes: nil)
    end.to raise_error /violates check constraint/
  end

  it 'raises if changed and already used in some meta data' do
    mk = FactoryBot.create(:meta_key_people, allowed_people_subtypes: ['Person'])
    FactoryBot.create(:meta_datum_people, meta_key: mk)
    expect do
      mk.update!(allowed_people_subtypes: ['PeopleGroup'])
    end.to raise_error /Cannot change allowed_people_subtypes/
  end

  it 'raises if not allowed value' do
    expect do
      FactoryBot.create(:meta_key_people, allowed_people_subtypes: ['Foo'])
    end.to raise_error /violates check constraint/
  end

end
