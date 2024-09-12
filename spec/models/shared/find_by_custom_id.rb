RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_can, 'it can'
end

RSpec.shared_examples 'be found via custom id' do
  before(:example) do
    @resource = FactoryBot.create(described_class.model_name.singular,
                                   get_metadata_and_previews: true)
  end

  context 'model itself' do
    context 'find_by_id_or_custom_url_id' do
      it 'with custom url' do
        custom_url = \
          FactoryBot.create(:custom_url,
                             Hash["#{described_class.model_name.singular}_id",
                                  @resource.id])
        expect(described_class.find_by_id_or_custom_url_id(custom_url.id)).to be
      end

      it 'with uuid' do
        expect(described_class.find_by_id_or_custom_url_id(@resource.id)).to be
      end
    end
  end
end
