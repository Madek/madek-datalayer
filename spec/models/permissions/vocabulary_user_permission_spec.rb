require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions.rb'

describe Permissions::VocabularyUserPermission do

  it 'is creatable via a factory' do
    expect { FactoryBot.create :vocabulary_user_permission }
      .not_to raise_error
  end

  context 'User and Vocabulary ' do

    before :each do
      @user = FactoryBot.create :user
      @creator = FactoryBot.create :user
      @vocabulary = FactoryBot.create :vocabulary
    end

    describe 'destroy_ineffective' do

      context %(for permission where all permission values are false \
                and user is not the responsible_user) do
        before :each do
          @permission = \
            FactoryBot.create(:vocabulary_user_permission,
                               view: false,
                               use: false,
                               user: (FactoryBot.create :user),
                               vocabulary: @vocabulary)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
