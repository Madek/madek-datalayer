require 'spec_helper'

describe User do
  context 'checks if a user can edit permissions for media resource' do
    before :example do
      @user = create(:user)
    end

    it 'responsible user' do
      [:media_entry, :collection, :filter_set].each do |resource_type|
        resource = create(resource_type, responsible_user: @user)
        expect(resource.user_permissions.where(user: @user)).not_to exist
        expect(@user.can_edit_permissions_for?(resource)).to be true
      end
    end

    it 'explicit edit permission' do
      [:media_entry, :collection, :filter_set].each do |resource_type|
        resource = create(resource_type, responsible_user: create(:user))
        resource.user_permissions << \
          create("#{resource_type}_user_permission",
                 user: @user,
                 edit_permissions: true)
        expect(resource.responsible_user).not_to eq @user
        expect(@user.can_edit_permissions_for?(resource)).to be true
      end
    end
  end
end
