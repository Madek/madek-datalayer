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

  it 'scope `with_usage_count` sorts by usage_count' do
    meta_key = FactoryGirl.create(:meta_key_keywords,
                                  keywords_alphabetical_order: true)
    # prepare keywords, shuffle to not accidentally rely on creation order
    keywords = Array.new(12) do
      FactoryGirl.create(:keyword, meta_key: meta_key)
    end.shuffle
    # create MD by reverse index, so order by usage count is same as array order
    keywords.reverse.each.with_index do |kw, n|
      (n + 1).times { FactoryGirl.create(:meta_datum_keywords, keywords: [kw]) }
    end

    # compare by expected usage_count number:
    counts = meta_key.keywords.with_usage_count.map(&:usage_count)
    expect(counts).to eq(counts.sort.reverse)
    # expect term order just to be sure:
    expect(meta_key.keywords.with_usage_count.map(&:term))
      .to eq keywords.map(&:term)
  end

end
