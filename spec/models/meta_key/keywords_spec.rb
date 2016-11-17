require 'spec_helper'
require Rails.root.join('spec',
                        'models',
                        'keyword',
                        'terms_for_sorting.rb')

describe 'sorting of the associated keywords' do

  include_context :datalayer_terms_for_sorting

  it 'sorts for keywords_alphabetical_order = true' do
    meta_key = FactoryGirl.create(:meta_key_keywords,
                                  keywords_alphabetical_order: true)
    terms.reverse.map do |term|
      FactoryGirl.create(:keyword, term: term, meta_key: meta_key)
    end

    expect(meta_key.keywords.map(&:term)).to be == terms
  end

end
