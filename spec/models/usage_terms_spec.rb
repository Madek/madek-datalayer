require 'spec_helper'

describe UsageTerms do
  describe 'validations' do
    let(:usage_terms) { build(:usage_terms) }
    let(:usage_terms_with_blank_fields) do
      build(:usage_terms, title: nil, version: nil, intro: nil, body: nil)
    end
    let(:usage_terms_without_title) { build(:usage_terms, title: nil) }
    let(:usage_terms_without_version) { build(:usage_terms, version: nil) }
    let(:usage_terms_without_intro) { build(:usage_terms, intro: nil) }
    let(:usage_terms_without_body) { build(:usage_terms, body: nil) }

    specify { expect(usage_terms).to be_valid }
    specify { expect(usage_terms_with_blank_fields).not_to be_valid }
    specify { expect(usage_terms_without_title).not_to be_valid }
    specify { expect(usage_terms_without_version).not_to be_valid }
    specify { expect(usage_terms_without_intro).not_to be_valid }
    specify { expect(usage_terms_without_body).not_to be_valid }
  end
end
