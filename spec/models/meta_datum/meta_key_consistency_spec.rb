require 'spec_helper'
require 'spec_helper_no_tx'

describe 'relations between meta_data and meta_keys' do

  before :all do
    @user = FactoryGirl.create(:user)
    @collection = FactoryGirl.create :collection
    FactoryGirl.create :meta_key_title
    FactoryGirl.create(:meta_datum_text,
                       collection: @collection,
                       value: 'Blah',
                       meta_key_id: 'test:title')
  end

  describe MetaDatum do

    describe %(changing the type to be incompatible) do
      it 'raises an error ' do
        expect do
          ActiveRecord::Base.transaction do
            ActiveRecord::Base.connection.execute \
              "UPDATE meta_data SET type = 'MetaDatum::TextDate' "
          end
        end.to raise_error \
          /types of related meta_data and meta_keys must be identical/
      end
    end

    describe %(creating a new meta_datum which relates
    to an imcompatible meta_key).strip do
      it 'raises an error' do
        meta_key = \
          FactoryGirl.create(:meta_key,
                             id: "test:#{Faker::Lorem.characters(10)}",
                             meta_datum_object_type: 'MetaDatum::Text')
        expect do
          MetaDatum::TextDate.transaction do
            ActiveRecord::Base.connection.execute <<-SQL
              INSERT INTO meta_data (type,
                                     meta_key_id,
                                     collection_id,
                                     created_by_id,
                                     string)
              VALUES ('MetaDatum::TextDate',
                      '#{meta_key.id}',
                      '#{@collection.id}',
                      '#{@user.id}',
                      'bla')
            SQL
          end
        end.to raise_error \
          /types of related meta_data and meta_keys must be identical/
      end
    end

    describe %(creating a new meta_datum where another meta_datum with same
    collection_id and meta_key_id already exists).strip do
      it 'raises an error' do
        meta_key = \
          FactoryGirl.create(:meta_key,
                             id: "test:#{Faker::Lorem.characters(10)}",
                             meta_datum_object_type: 'MetaDatum::Text')
        MetaDatum::Text.transaction do
          ActiveRecord::Base.connection.execute <<-SQL
            INSERT INTO meta_data (type,
                                   meta_key_id,
                                   collection_id,
                                   created_by_id,
                                   string)
            VALUES ('MetaDatum::Text',
                    '#{meta_key.id}',
                    '#{@collection.id}',
                    '#{@user.id}',
                    'bla')
          SQL
        end

        expect do
          MetaDatum::Text.transaction do
            ActiveRecord::Base.connection.execute \
              "INSERT INTO meta_data (type,meta_key_id,collection_id)
               VALUES ('MetaDatum::Text','#{meta_key.id}','#{@collection.id}')"
          end
        end.to raise_error /duplicate key value violates unique constraint/
      end
    end

  end

  describe MetaDatum::Keyword do

    it 'raises if meta_key_id is inconsistent for meta_data and keywords' do
      meta_datum_keywords = FactoryGirl.create(:meta_datum_keywords)
      vocabulary = FactoryGirl.create(:vocabulary, id: Faker::Lorem.characters(8))
      meta_key = \
        FactoryGirl.create(:meta_key_keywords,
                           id: "#{vocabulary.id}:#{Faker::Lorem.characters(8)}")
      keyword = FactoryGirl.create(:keyword, meta_key: meta_key)

      expect do
        MetaDatum::Keyword.transaction do
          ActiveRecord::Base.connection.execute <<-SQL
            INSERT INTO meta_data_keywords (meta_datum_id,
                                            keyword_id,
                                            created_by_id)
            VALUES ('#{meta_datum_keywords.id}',
                    '#{keyword.id}',
                    '#{@user.id}')
          SQL
        end
      end.to raise_error /meta_key_id for meta_data and keywords must be identical/
    end

  end

  describe MetaKey do

    describe %(changing the type to be incomaptible) do
      it 'raises an error ' do
        expect do
          ActiveRecord::Base.transaction do
            ActiveRecord::Base.connection.execute \
              "UPDATE meta_keys SET meta_datum_object_type = 'MetaDatum::TextDate'"
          end
        end.to raise_error \
          /types of related meta_data and meta_keys must be identical/
      end
    end

  end

end
