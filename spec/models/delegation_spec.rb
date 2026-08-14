require 'spec_helper'

describe Delegation do
  describe '.with_members_count, .with_resources_count and .filter_by' do
    def scoped
      Delegation.with_members_count.with_resources_count
    end

    it 'counts direct and group members' do
      delegation = create(:delegation)
      delegation.users << [create(:user), create(:user)]
      delegation.groups << create(:group, :with_user)

      row = scoped.find(delegation.id)
      expect(row.members_count).to eq 3
      expect(row.group_members_count).to eq 1
    end

    it 'counts resources' do
      delegation = create(:delegation,
                          :with_media_entries,
                          :with_collections,
                          entries_amount: 3)

      expect(scoped.find(delegation.id).resources_count).to eq 5
    end

    it 'returns a users-only delegation when filtering by user id' do
      user = create(:user)
      delegation = create(:delegation)
      delegation.users << user
      create(:delegation).users << create(:user)

      result = scoped.filter_by(nil, user.id.to_s)
      expect(result.map(&:id)).to eq [delegation.id]
      expect(result.first.members_count).to eq 1
      expect(result.first.group_members_count).to eq 0
    end

    it 'returns a groups-only delegation when filtering by group id' do
      group = create(:group, :with_user)
      delegation = create(:delegation)
      delegation.groups << group
      create(:delegation).groups << create(:group, :with_user)

      result = scoped.filter_by(nil, group.id.to_s)
      expect(result.map(&:id)).to eq [delegation.id]
      expect(result.first.members_count).to eq 1
      expect(result.first.group_members_count).to eq 1
    end

    it 'returns one row when a matched user belongs to a delegation with several groups' do
      user = create(:user)
      delegation = create(:delegation)
      delegation.users << user
      3.times { delegation.groups << create(:group, :with_user) }

      result = scoped.filter_by(nil, user.id.to_s)
      expect(result.map(&:id)).to eq [delegation.id]
      expect(result.first.members_count).to eq 4
      expect(result.first.group_members_count).to eq 3
    end
  end

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
