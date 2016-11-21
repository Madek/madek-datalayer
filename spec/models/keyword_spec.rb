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

  it 'trims whitespace when creating a kw' do
    spaces = (Madek::Constants::SPECIAL_WHITESPACE_CHARS + ['', "\n"]).shuffle.join
    spaced_term = spaces + 'term' + spaces
    expect(FactoryGirl.create(:keyword, term: spaced_term).term)
      .to be == 'term'
  end

  it 'term can\'t be empty or whitespace only' do
    # NOTE: should be DB constraint, maybe raises something from PG?
    expected_error = [ActiveRecord::RecordInvalid, /term can't be blank/i]

    empty_string = ''
    only_spaces = (
      Madek::Constants::SPECIAL_WHITESPACE_CHARS + ['', "\n"]).shuffle.join

    expect { FactoryGirl.create(:keyword, term: empty_string) }
      .to raise_error(*expected_error)
    expect { FactoryGirl.create(:keyword, term: only_spaces) }
      .to raise_error(*expected_error)
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
