require 'spec_helper'

describe EditSession do

  describe 'Creation' do

    it 'should be producible by a factory' do

      expect do
        FactoryBot.create :edit_session,
                           media_entry: FactoryBot.create(:media_entry)
      end.not_to raise_error

      expect do
        FactoryBot.create :edit_session,
                           collection: FactoryBot.create(:collection)
      end.not_to raise_error

    end

    it %(should raise an error if neither media entry, \
         no collection is provided) do

      expect { FactoryBot.create :edit_session }
        .to raise_error ActiveRecord::RecordInvalid

    end

    it %(should raise an error if 2 or more of media entry, \
         collection is provided) do

      expect do
        FactoryBot.create :edit_session,
                           media_entry: FactoryBot.create(:media_entry),
                           collection: FactoryBot.create(:collection)
      end
        .to raise_error ActiveRecord::StatementInvalid

    end

  end
end
