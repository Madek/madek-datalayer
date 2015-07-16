require 'spec_helper'

describe Keyword do
  describe '#creator' do
    it 'returns an user who created a keyword term' do
      keyword = FactoryGirl.create :keyword
      creator_user = FactoryGirl.create :user
      common_user  = FactoryGirl.create :user

      FactoryGirl.create(:meta_datum_keyword,
                         user: creator_user,
                         keyword: keyword)
      FactoryGirl.create(:meta_datum_keyword,
                         user: common_user,
                         keyword: keyword)

      expect(keyword.reload.creator).to eq(creator_user)
    end
  end
end
