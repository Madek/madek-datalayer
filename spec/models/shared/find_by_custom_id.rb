RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_can, 'it can'
end

RSpec.shared_examples 'be found via custom id' do
  before(:example) do
    @resource = FactoryBot.create(described_class.model_name.singular,
                                   get_metadata_and_previews: true)
  end

  context 'model itself' do
    context 'find' do
      it 'with custom url' do
        custom_url = \
          FactoryBot.create(:custom_url,
                             Hash["#{described_class.model_name.singular}_id",
                                  @resource.id])
        expect(described_class.find(custom_url.id)).to be
      end

      it 'with uuid' do
        expect(described_class.find(@resource.id)).to be
      end
    end

    context 'find_by_id' do
      it 'with custom url' do
        custom_url = \
          FactoryBot.create(:custom_url,
                             Hash["#{described_class.model_name.singular}_id",
                                  @resource.id])
        expect(described_class.find_by_id(custom_url.id)).to be
      end

      it 'with uuid' do
        expect(described_class.find_by_id(@resource.id)).to be
      end
    end

    context 'not allowed methods' do
      it 'find_by is prevented' do
        expect do
          described_class.find_by
        end.to raise_error NoMethodError
      end

      it 'find_by! is prevented' do
        expect do
          described_class.find_by!
        end.to raise_error NoMethodError
      end
    end
  end

  context 'model\'s relation' do
    context 'find' do
      it 'with custom url' do
        custom_url = \
          FactoryBot.create(:custom_url,
                             Hash["#{described_class.model_name.singular}_id",
                                  @resource.id,
                                  :is_primary, true])
        expect(
          described_class
          .joins(:custom_urls)
          .where(custom_urls: { is_primary: true })
          .find(custom_url.id)
        ).to be
      end

      it 'with uuid' do
        expect(
          described_class
          .where(get_metadata_and_previews: true)
          .find(@resource.id)
        ).to be
      end
    end

    context 'find_by_id' do
      it 'with custom url' do
        custom_url = \
          FactoryBot.create(:custom_url,
                             Hash["#{described_class.model_name.singular}_id",
                                  @resource.id,
                                  :is_primary, true])
        expect(
          described_class
          .joins(:custom_urls)
          .where(custom_urls: { is_primary: true })
          .find_by_id(custom_url.id)
        ).to be
      end

      it 'with uuid' do
        expect(
          described_class
          .where(get_metadata_and_previews: true)
          .find(@resource.id)
        ).to be
      end
    end

    context 'not allowed methods' do
      it 'find_by is prevented' do
        expect do
          described_class
          .joins(:custom_urls)
          .where(custom_urls: { is_primary: true })
          .find_by
        end.to raise_error NoMethodError
      end

      it 'find_by! is prevented' do
        expect do
          described_class
          .joins(:custom_urls)
          .where(custom_urls: { is_primary: true })
          .find_by!
        end.to raise_error NoMethodError
      end
    end
  end
end
