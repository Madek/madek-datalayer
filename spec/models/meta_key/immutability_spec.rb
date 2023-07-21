require 'spec_helper'
require 'spec_helper_no_tx'

describe 'the namespace madek_core' do

  before :all do

    ActiveRecord::Base.connection.execute  \
      'SET session_replication_role = REPLICA;'

    FactoryBot.create :meta_key_core_title

    ActiveRecord::Base.connection.execute  \
      'SET session_replication_role = DEFAULT;'

  end

  describe 'adding new meta_keys to it' do

    it "raises an exception 'may not be extended'" do
      expect do
        MetaKey.transaction do
          MetaKey.connection.execute \
            %(INSERT INTO meta_keys (id, meta_datum_object_type, vocabulary_id) \
              VALUES ('madek_core:foo','MetaDatum::Text','madek_core'))
        end
      end.to raise_error(/may not be extended/)
    end

  end

  context 'with the MetaKey madek_core:title' do

    it 'madek_core:title exists' do
      expect(MetaKey.find('madek_core:title')).to be
    end

    describe 'deleting it' do
      it "raises an exception 'may not be deleted'" do
        expect do
          MetaKey.transaction do
            MetaKey.connection.execute \
              "DELETE FROM meta_keys WHERE id = 'madek_core:title'"
          end
        end.to raise_error(/may not be deleted/)
      end
    end

    describe 'mutating it' do
      it "is allowed for editable columns" do
        mk = MetaKey.find_by_id('madek_core:title')
        mk.update(labels: { de: 'Neuer Titel', en: 'New Title' })
        mk.reload
        expect(mk.labels['en']).to eq 'New Title'
        expect(mk.labels['de']).to eq 'Neuer Titel'
      end

      context "raises an exception for readonly columns" do
        it "normal value comparison" do
          expect do
            MetaKey.transaction do
              MetaKey.connection.execute <<-SQL
              UPDATE meta_keys
              SET meta_datum_object_type = 'MetaDatum::People',
                  allowed_people_subtypes = ARRAY['Person']
              WHERE id = 'madek_core:title'
              SQL
            end
          end.to raise_error(/only certain attributes.*may be modified/i)
        end

        it "normal value with null comparison" do
          expect do
            MetaKey.transaction do
              MetaKey.connection.execute <<-SQL
                UPDATE meta_keys
                SET admin_comment = 'some admin comment'
                WHERE id = 'madek_core:title'
              SQL
            end
          end.to raise_error(/only certain attributes.*may be modified/i)
        end
      end
    end

  end

end
