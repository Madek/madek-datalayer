require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions.rb'

describe Permissions::VocabularyApiClientPermission do

  it 'is creatable via a factory' do
    expect { FactoryBot.create :vocabulary_api_client_permission }
      .not_to raise_error
  end

  context 'ApiClient and Vocabulary ' do

    before :each do
      @api_client = FactoryBot.create :api_client
      @creator = FactoryBot.create :api_client
      @vocabulary = FactoryBot.create :vocabulary
    end

    describe 'destroy_ineffective' do

      context %(for permission where all permission values are false \
                and api_client is not the responsible_api_client) do
        before :each do
          @permission = \
            FactoryBot.create(:vocabulary_api_client_permission,
                               view: false,
                               use: false,
                               api_client: (FactoryBot.create :api_client),
                               vocabulary: @vocabulary)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
