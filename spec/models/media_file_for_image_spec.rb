require 'spec_helper'

describe 'media_file_for_image' do
  context 'Creation' do
    it 'should be producible by a factory' do
      expect { FactoryGirl.create :media_file_for_image }.not_to raise_error
    end
  end
end
