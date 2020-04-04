require 'spec_helper'
require 'models/shared/orderable'
require 'models/shared/assigning_localized_fields'
require 'models/shared/blank_localized_fields'

describe MetaKey do
  describe '.object_types' do
    it 'returns an array with unique and sorted values' do
      expect(described_class.object_types).to eq(
        %w(MetaDatum::JSON
           MetaDatum::Keywords
           MetaDatum::People
           MetaDatum::Roles
           MetaDatum::Text
           MetaDatum::TextDate)
      )
    end
  end

  describe '#enabled_for' do
    it 'returns an array' do
      meta_key = create(:meta_key_text)

      expect(meta_key.enabled_for).to be_an(Array)
      expect(meta_key.enabled_for).to eq %w(Entries Sets)
    end
  end

  it_behaves_like 'orderable' do
    let(:parent_scope) { :vocabulary }
  end

  it_ensures 'assigning localized fields'
  it_handles 'blank localized fields' do
    let(:factory_name) { :meta_key_text }
  end
end
