RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_handles, 'handles'
end

RSpec.shared_examples 'blank localized fields' do |without_hints = true|
  describe 'non blank values for localized fields' do
    it 'raises error for blank labels' do
      expect do
        create(
          factory_name,
          labels: {
            de: '',
            en: ' ',
            fr: nil
          })
      end.to raise_error(ActiveRecord::StatementInvalid)
    end

    it 'does not raise error for nil labels' do
      expect do
        FactoryGirl.create(
          factory_name,
          labels: {
            de: nil,
            en: nil
          })
      end.not_to raise_error
    end

    it 'raises error for blank descriptions' do
      expect do
        create(
          factory_name,
          descriptions: {
            de: '',
            en: ' ',
            fr: nil
          })
      end
    end

    it 'does not raise error for nil descriptions' do
      expect do
        FactoryGirl.create(
          factory_name,
          descriptions: {
            de: nil,
            en: nil
          })
      end.not_to raise_error
    end

    unless without_hints
      it 'raises error for blank hints' do
        expect do
          create(
            factory_name,
            hints: {
              de: '',
              en: ' ',
              fr: nil
            })
        end
      end

      it 'does not raise error for nil hints' do
        expect do
          FactoryGirl.create(
            factory_name,
            hints: {
              de: nil,
              en: nil
            })
        end.not_to raise_error
      end
    end
  end
end
