RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_ensures, 'ensures'
end

RSpec.shared_examples 'assigning localized fields' do |without_hints = true|
  describe 'mass assignment' do
    it 'assigns localized labels' do
      model_instance = described_class.new(
        id: 'foo:bar',
        labels: {
          de: 'label DE',
          en: 'label EN',
          fr: ''
        }
      )

      expect(model_instance.label).to eq 'label DE'
      expect(model_instance.label(:de)).to eq 'label DE'
      expect(model_instance.label(:en)).to eq 'label EN'
      expect(model_instance.label(:fr)).to be_nil
      expect(model_instance.labels).to eq(
        'de' => 'label DE',
        'en' => 'label EN',
        'fr' => nil
      )
    end

    it 'assigns localized descriptions' do
      model_instance = described_class.new(
        id: 'foo:bar',
        descriptions: {
          de: 'description DE',
          en: 'description EN',
          fr: ''
        }
      )

      expect(model_instance.description).to eq 'description DE'
      expect(model_instance.description(:de)).to eq 'description DE'
      expect(model_instance.description(:en)).to eq 'description EN'
      expect(model_instance.description(:fr)).to be_nil
      expect(model_instance.descriptions).to eq(
        'de' => 'description DE',
        'en' => 'description EN',
        'fr' => nil
      )
    end

    unless without_hints
      it 'assigns localized hints' do
        model_instance = described_class.new(
          id: 'foo:bar',
          hints: {
            de: 'hint DE',
            en: 'hint EN',
            fr: ''
          }
        )

        expect(model_instance.hint).to eq 'hint DE'
        expect(model_instance.hint(:de)).to eq 'hint DE'
        expect(model_instance.hint(:en)).to eq 'hint EN'
        expect(model_instance.hint(:fr)).to be_nil
        expect(model_instance.hints).to eq(
          'de' => 'hint DE',
          'en' => 'hint EN',
          'fr' => nil
        )
      end
    end
  end
end
