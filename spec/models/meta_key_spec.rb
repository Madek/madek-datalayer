require 'spec_helper'
require 'models/shared/saving_empty_strings'
require 'models/shared/orderable'
require 'models/shared/assigning_localized_fields'

describe MetaKey do
  describe '.object_types' do
    it 'returns an array with unique and sorted values' do
      expect(described_class.object_types)
        .to eq(described_class.object_types.uniq)

      expect(described_class.object_types)
        .to eq(described_class.object_types.sort)
    end
  end

  describe '#enabled_for' do
    it 'returns an array' do
      meta_key = create(:meta_key_text)

      expect(meta_key.enabled_for).to be_an(Array)
      expect(meta_key.enabled_for).to eq %w(Entries Sets)
    end
  end

  it_ensures 'saving empty strings' do
    let(:model) { create :meta_key_text }
  end

  it_behaves_like 'orderable' do
    let(:parent_scope) { :vocabulary }
  end

  it_ensures 'assigning localized fields'
end
