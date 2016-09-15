require 'spec_helper'

describe Keyword do
  describe '#creator' do
    it 'returns an user who created a keyword term' do
      keyword = FactoryGirl.create :keyword
      creator_user = FactoryGirl.create :user
      common_user  = FactoryGirl.create :user

      FactoryGirl.create(:meta_datum_keyword,
                         created_by: creator_user,
                         keyword: keyword)
      FactoryGirl.create(:meta_datum_keyword,
                         created_by: common_user,
                         keyword: keyword)

      expect(keyword.reload.creator).to eq(creator_user)
    end
  end

  describe 'UTF8 NFC normalization' do

    it "confirm that ruby :nfd isn't equal to :nfc" do
      expect('Überweiß'.unicode_normalize(:nfd)).not_to \
        be == 'Überweiß'.unicode_normalize(:nfc)
    end

    it 'converts to NFC when creating a kw' do
      expect(FactoryGirl.create(
        :keyword, term: 'Überweiß'.unicode_normalize(:nfd)
      ).term).to \
        be == 'Überweiß'.unicode_normalize(:nfc)
    end

    it 'converts to NFC when updating a kw ' do
      kw = FactoryGirl.create(:keyword, \
                              term: 'Blah'.unicode_normalize(:nfd))
      kw.update_attributes! term: 'Überweiß'.unicode_normalize(:nfd)
      expect(kw.term).to be == 'Überweiß'.unicode_normalize(:nfc)
    end

  end

end
