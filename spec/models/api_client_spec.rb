require 'spec_helper'

describe ApiClient do

  it 'should be producible by a factory' do
    expect { FactoryBot.create :api_client }.not_to raise_error
  end

  context 'an existing Collection' do

    before :each do
      @api_client = FactoryBot.create :api_client
    end

  end

end
