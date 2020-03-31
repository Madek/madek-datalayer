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

    context 'for different meta key' do
      it 'ends with success' do
        meta_key = create :meta_key_roles, id: 'test:different-roles'
        role = create :role, meta_key: meta_key

        expect { create(:role, labels: { de: role.label }) }.not_to raise_error
      end
    end
  end

end
