require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions.rb'
require 'models/shared/permittable_for'

describe Permissions::CollectionUserPermission do

  it 'is creatable via a factory' do
    expect { FactoryBot.create :collection_user_permission }.not_to raise_error
  end

  context 'User and MediaEntry ' do

    before :each do
      @user = FactoryBot.create :user
      @creator = FactoryBot.create :user
      @collection = FactoryBot.create :collection
    end

    describe 'destroy_ineffective' do

      context ' for permissions where the user is the reponsible_user' do
        before :each do
          @permission = FactoryBot.create(:collection_user_permission,
                                           get_metadata_and_previews: true,
                                           user: @collection.responsible_user,
                                           collection: @collection)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

      context %(for permission where all permission values are false \
               and user is not the responsible_user) do
        before :each do
          @permission = FactoryBot.create(:collection_user_permission,
                                           get_metadata_and_previews: false,
                                           edit_metadata_and_relations: false,
                                           user: (FactoryBot.create :user),
                                           collection: @collection)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

  it_implements '.permitted_for?' do
    let(:resource) { create(:collection) }
  end
end
