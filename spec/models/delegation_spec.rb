require 'spec_helper'

describe Delegation do
  context 'number of required supervisors', skip: 'After introduction of constraints' do
    it 'raises an error when creating a delegation without at least one supervisor' do
      id = SecureRandom.uuid
      expect { create(:delegation, id: id) }
        .to raise_error(/No associated row in delegations_supervisors for delegation_id #{id}/)
    end

    it 'raises an error when trying to delete the last supervisor of a delegation' do
      ActiveRecord::Base.transaction do
        @d = FactoryBot.create(:delegation)
        @d.supervisors << FactoryBot.create(:user)
        @d.supervisors << FactoryBot.create(:user)
      end

      expect { @d.supervisors.delete_all }
        .to raise_error(/At least one entry in delegations_supervisors for delegation_id #{@d.id} must exist/)

      expect(@d.supervisors.count).to eq 2
    end
  end
end
