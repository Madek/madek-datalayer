require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions.rb'

describe Permissions::VocabularyGroupPermission do

  it 'is creatable via a factory' do
    expect { FactoryBot.create :vocabulary_group_permission }
      .not_to raise_error
  end

  context 'Group and Vocabulary ' do

    before :each do
      @group = FactoryBot.create :group
      @creator = FactoryBot.create :group
      @vocabulary = FactoryBot.create :vocabulary
    end

    describe 'destroy_ineffective' do

      context %(for permission where all permission values are false \
                and group is not the responsible_group) do
        before :each do
          @permission = \
            FactoryBot.create(:vocabulary_group_permission,
                               view: false,
                               use: false,
                               group: (FactoryBot.create :group),
                               vocabulary: @vocabulary)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
