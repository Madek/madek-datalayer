require 'spec_helper'
require 'models/shared/orderable'
require_relative 'shared/previous_ids'

describe Keyword do
  describe '#creator' do
    it 'returns an user who created a keyword term' do
      keyword = FactoryBot.create :keyword
      creator_user = FactoryBot.create :user
      common_user  = FactoryBot.create :user

      FactoryBot.create(:meta_datum_keyword,
                         created_by: creator_user,
                         keyword: keyword)
      FactoryBot.create(:meta_datum_keyword,
                         created_by: common_user,
                         keyword: keyword)

      expect(keyword.reload.creator).to eq(creator_user)
    end
  end

  it 'trims whitespace when creating a kw' do
    spaces = (Madek::Constants::SPECIAL_WHITESPACE_CHARS + ['', "\n"]).shuffle.join
    spaced_term = spaces + 'term' + spaces
    expect(FactoryBot.create(:keyword, term: spaced_term).term)
      .to be == 'term'
  end

  it 'term can\'t be empty or whitespace only' do
    # NOTE: should be DB constraint, maybe raises something from PG?
    expected_error = [ActiveRecord::RecordInvalid, /term can't be blank/i]

    empty_string = ''
    only_spaces = (
      Madek::Constants::SPECIAL_WHITESPACE_CHARS + ['', "\n"]).shuffle.join

    expect { FactoryBot.create(:keyword, term: empty_string) }
      .to raise_error(*expected_error)
    expect { FactoryBot.create(:keyword, term: only_spaces) }
      .to raise_error(*expected_error)
  end

  describe 'UTF8 NFC normalization' do

    it "confirm that ruby :nfd isn't equal to :nfc" do
      expect('Überweiß'.unicode_normalize(:nfd)).not_to \
        be == 'Überweiß'.unicode_normalize(:nfc)
    end

    it 'converts to NFC when creating a kw' do
      expect(FactoryBot.create(
        :keyword, term: 'Überweiß'.unicode_normalize(:nfd)
      ).term).to \
        be == 'Überweiß'.unicode_normalize(:nfc)
    end

    it 'converts to NFC when updating a kw ' do
      kw = FactoryBot.create(:keyword, \
                              term: 'Blah'.unicode_normalize(:nfd))
      kw.update! term: 'Überweiß'.unicode_normalize(:nfd)
      expect(kw.term).to be == 'Überweiß'.unicode_normalize(:nfc)
    end

  end

  it_behaves_like 'orderable' do
    let(:parent_scope) { :meta_key }
  end

  describe '#merge_to' do
    let(:keyword) { create(:keyword) }
    let(:receiver) { create(:keyword) }

    it 'deletes keyword' do
      expect(keyword).to receive(:destroy!)

      keyword.merge_to(receiver)
    end

    it 'remembers previous id' do
      expect { keyword.merge_to(receiver) }.to change {
        PreviousIds::PreviousKeywordId
          .where(previous_id: keyword.id, keyword_id: receiver.id)
          .count
      }.by(1)
    end
  end

  include_examples 'previous ids'
end
