require 'spec_helper'
require 'spec_helper_no_tx'

describe "allowed people subtypes for type 'MetaDatum::People'" do

  it 'raises if no value provided' do
    expect do
      FactoryBot.create(:meta_key_people, allowed_people_subtypes: nil)
    end.to raise_error /violates check constraint/
  end

end
