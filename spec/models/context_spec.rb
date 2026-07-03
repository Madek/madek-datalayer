require 'spec_helper'
require 'models/shared/assigning_localized_fields'

describe Context do
  it_ensures 'assigning localized fields', without_hints: true

  describe 'permissions' do
    let(:context) { FactoryBot.create :context }
    let(:user) { FactoryBot.create :user }
    let(:group) { FactoryBot.create :group }

    it 'is viewable and usable by anyone by default' do
      expect(context.viewable_by_public?).to be true
      expect(context.usable_by_public?).to be true
      expect(context.viewable_by_user?(user)).to be true
      expect(context.usable_by_user?(user)).to be true
      expect(Context.viewable_by_user_or_public).to include(context)
      expect(Context.viewable_by_user_or_public(user)).to include(context)
    end

    context 'when public view/use is disabled' do
      let(:context) do
        FactoryBot.create :context,
                           enabled_for_public_view: false,
                           enabled_for_public_use: false
      end

      it 'is not viewable/usable by an unrelated user' do
        expect(context.viewable_by_user?(user)).to be false
        expect(context.usable_by_user?(user)).to be false
        expect(Context.viewable_by_user_or_public(user)).not_to include(context)
      end

      it 'is viewable by a user with an explicit view permission' do
        FactoryBot.create :context_user_permission,
                           context: context, user: user, view: true, use: false
        expect(context.viewable_by_user?(user)).to be true
        expect(context.usable_by_user?(user)).to be false
      end

      it 'is usable by a user in a group with an explicit use permission' do
        user.groups << group
        FactoryBot.create :context_group_permission,
                           context: context, group: group, view: false, use: true
        expect(context.usable_by_user?(user)).to be true
        expect(context.viewable_by_user?(user)).to be false
      end

      it 'is not viewable/usable by a group member after the group permission is removed' do
        user.groups << group
        permission = FactoryBot.create :context_group_permission,
                                        context: context, group: group,
                                        view: true, use: true
        expect(context.viewable_by_user?(user)).to be true

        permission.destroy
        expect(context.viewable_by_user?(user)).to be false
        expect(context.usable_by_user?(user)).to be false
      end
    end
  end
end
