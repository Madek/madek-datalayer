require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions.rb'
require 'models/shared/permittable_for'

describe Permissions::MediaEntryUserPermission do

  it 'is creatable via a factory' do
    expect { FactoryBot.create :media_entry_user_permission }.not_to raise_error
  end

  context 'User and MediaEntry ' do

    before :each do
      @user = FactoryBot.create :user
      @creator = FactoryBot.create :user
      @media_entry = FactoryBot.create :media_entry
    end

    describe 'destroy_ineffective' do

      context ' for permissions where the user is the reponsible_user' do
        before :each do
          @permission = FactoryBot.create(:media_entry_user_permission,
                                           get_full_size: true,
                                           user: @media_entry.responsible_user,
                                           media_entry: @media_entry)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

      context %(for permission where all permission values are false \
                and user is not the responsible_user) do
        before :each do
          @permission = FactoryBot.create(:media_entry_user_permission,
                                           get_metadata_and_previews: false,
                                           get_full_size: false,
                                           edit_metadata: false,
                                           edit_permissions: false,
                                           user: (FactoryBot.create :user),
                                           media_entry: @media_entry)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

  it_implements '.permitted_for?' do
    let(:resource) { create(:media_entry) }
  end
end
