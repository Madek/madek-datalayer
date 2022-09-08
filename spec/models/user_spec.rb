require 'spec_helper'

describe User do
  describe 'permissions' do
    let(:user) { create(:user) }

    context 'checks if a user can edit permissions for media resource' do
      it 'responsible user' do
        [:media_entry, :collection].each do |resource_type|
          resource = create(resource_type, responsible_user: user)
          expect(resource.user_permissions.where(user: user)).not_to exist
          expect(user.can_edit_permissions_for?(resource)).to be true
        end
      end

      it 'explicit edit permission' do
        [:media_entry, :collection].each do |resource_type|
          resource = create(resource_type, responsible_user: create(:user))
          resource.user_permissions << \
            create("#{resource_type}_user_permission",
                   user: user,
                   edit_permissions: true)
          expect(resource.responsible_user).not_to eq user
          expect(user.can_edit_permissions_for?(resource)).to be true
        end
      end
    end
  end

  describe '#reset_usage_terms' do
    let(:usage_terms) { create(:usage_terms) }
    let(:user) { create(:user, accepted_usage_terms: usage_terms) }

    it 'resets usage terms' do
      expect { user.reset_usage_terms }.to change {
        user.accepted_usage_terms_id
      }.from(usage_terms.id).to(nil)
    end
  end

  describe '#all_delegations' do
    let(:user) { create(:user) }
    let!(:another_user) { create(:user) }
    let(:group) { create(:group) }
    let(:delegation_with_user) { create(:delegation) }
    let(:delegation_with_group) { create(:delegation) }
    let!(:another_delegation) { create(:delegation) }

    before do
      group.users << user
      delegation_with_user.users << user
      delegation_with_group.groups << group
      another_delegation.users << another_user
    end

    it 'returns delegations along with those from groups the user belongs to' do
      expect(user.all_delegations).to eq(
        [
          delegation_with_user,
          delegation_with_group
        ]
      )
    end
  end
end
