require 'spec_helper'

describe Role do

  it 'should be producible by a factory' do
    expect { create(:role) }.not_to raise_error
  end

  describe 'Creating with the same labels' do
    context 'for the same meta key' do
      it 'raises error' do
        role = create :role

        expect do
          create(:role, labels: { de: role.label })
        end.to raise_error ActiveRecord::RecordNotUnique
      end
    end
  end
end
