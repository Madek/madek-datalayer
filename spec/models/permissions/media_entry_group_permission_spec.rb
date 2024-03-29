require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions.rb'

describe Permissions::MediaEntryGroupPermission do

  it 'is creatable via a factory' do
    expect { FactoryBot.create :media_entry_group_permission }.not_to raise_error
  end

  context 'Group and MediaEntry ' do

    before :each do
      @group = FactoryBot.create :group
      @creator = FactoryBot.create :group
      @media_entry = FactoryBot.create :media_entry
    end

    describe 'destroy_ineffective' do

      context %(for permission where all permission values are false \
                and group is not the responsible_group) do
        before :each do
          @permission = FactoryBot.create(:media_entry_group_permission,
                                           get_metadata_and_previews: false,
                                           get_full_size: false,
                                           edit_metadata: false,
                                           group: (FactoryBot.create :group),
                                           media_entry: @media_entry)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
