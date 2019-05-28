require 'spec_helper'

describe Workflow do
  it 'is creatable by factory' do
    expect { create :workflow }.not_to raise_error
  end

  context 'when created' do
    it 'has is_active set to true by default' do
      expect(subject.is_active).to be true
    end
  end
end
