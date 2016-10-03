require 'spec_helper'
require 'spec_helper_no_tx'

describe MetaDatum::Text do
  before :example do
    PgTasks.truncate_tables
  end

  describe 'Creation' do

    it 'should not raise an error ' do
      expect { FactoryGirl.create :meta_datum_text }.not_to raise_error
    end

    it 'should not be nil' do
      expect(FactoryGirl.create :meta_datum_text).to be
    end

    it 'should be persisted' do
      expect(FactoryGirl.create :meta_datum_text).to be_persisted
    end

    it 'should raise an error for empty created_by' do
      expect { FactoryGirl.create :meta_datum_text, created_by: nil }
        .to raise_error /created_by in table meta_data may not be null/
    end

    it 'should auto delete for empty string' do
      expect { FactoryGirl.create :meta_datum_text, string: nil }
        .not_to change { MetaDatum.count }
    end

    context 'whitespace sanitization' do
      it 'should sanitize special whitespace char and auto delete' do
        string = Madek::Constants::SPECIAL_WHITESPACE_CHARS.sample
        # using value= because of sanitization
        expect { FactoryGirl.create :meta_datum_text, value: string }
          .not_to change { MetaDatum.count }
      end

      it 'whitespace regexp should not match on newlines' do
        string = 'foo\n\r\n\rbar'
        expect { FactoryGirl.create :meta_datum_text, value: string }
          .to change { MetaDatum.count }
      end
    end
  end

  context 'UTF8 NFC normalization' do

    it "confirm that ruby :nfd isn't equal to :nfc" do
      expect('Überweiß'.unicode_normalize(:nfd)).not_to \
        be == 'Überweiß'.unicode_normalize(:nfc)
    end

    it 'converts to NFC when creating a meta datum' do
      expect(FactoryGirl.create(
        :meta_datum_text, string: 'Überweiß'.unicode_normalize(:nfd)
      ).value).to \
        be == 'Überweiß'.unicode_normalize(:nfc)
    end

    it 'converts to NFC when updating a meta datum' do
      mdt = FactoryGirl.create(:meta_datum_text, \
                               string: 'Blah'.unicode_normalize(:nfd))
      mdt.update_attributes! string: 'Überweiß'.unicode_normalize(:nfd)
      expect(mdt.value).to be == 'Überweiß'.unicode_normalize(:nfc)
    end

  end

  context 'an existing MetaDatumString instance ' do

    before :each do
      @mds = FactoryGirl.create :meta_datum_text, string: 'original value'
    end

    describe 'the string field' do

      it 'should be assignable' do
        expect { @mds.string = 'new string value' }.not_to raise_error
      end

      it 'should be persisted ' do
        @mds.string = 'new string value'
        @mds.save
        expect(@mds.reload.string).to be == 'new string value'
      end

      describe 'the value alias' do

        it 'should be accessible' do
          expect { @mds.value }.not_to raise_error
        end

        it 'should be setable and persited' do
          @mds.value = 'new string value'
          @mds.save
          expect(@mds.reload.value).to be == 'new string value'
        end

        it 'should alias string' do
          @mds.string = 'Blah'
          @mds.save
          expect(@mds.reload.value).to be == 'Blah'
        end

      end

    end

    describe 'the to_s method' do

      it 'should return the string value' do
        expect(@mds.to_s).to be == 'original value'
      end

    end

    describe 'required context keys validation' do

      it 'validates correctly' do
        media_entry = FactoryGirl.create(:media_entry, is_published: true)
        meta_datum_text = FactoryGirl.create(:meta_datum_text,
                                             meta_key_id: 'test:string',
                                             media_entry: media_entry)

        validation_context_id = 'upload'
        Context.find_by_id(validation_context_id) \
          or FactoryGirl.create(:context, id: validation_context_id)
        AppSetting.first.update_attributes! \
          contexts_for_validation: [validation_context_id]
        FactoryGirl.create(:context_key,
                           context_id: validation_context_id,
                           is_required: true)

        expect(meta_datum_text.update_attributes(value: nil)).to be false
        meta_datum_text.reload
        expect(meta_datum_text.value).not_to be_blank
      end

    end

  end

end
