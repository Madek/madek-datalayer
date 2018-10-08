RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_ensures, 'ensures'
end

RSpec.shared_examples 'assigning localized fields' do
  describe 'assignment from pure attribute' do
    let(:label) { Faker::Lorem.word }
    let(:description) { Faker::Lorem.paragraph }
    let(:hint) { Faker::Lorem.sentence }

    it 'assigns localized label from pure label' do
      model_instance = described_class.new
      model_instance.label = label

      expect(model_instance.label(:de)).to eq label
      expect(model_instance.labels).to eq('de' => label)
    end

    it 'assigns localized description from pure description' do
      model_instance = described_class.new
      model_instance.description = description

      expect(model_instance.description(:de)).to eq description
      expect(model_instance.descriptions).to eq('de' => description)
    end

    it 'assigns localized hint from pure hint' do
      model_instance = described_class.new
      model_instance.hint = hint

      expect(model_instance.hint(:de)).to eq hint
      expect(model_instance.hints).to eq('de' => hint)
    end
  end

  describe 'mass assignment' do
    it 'assigns localized label' do
      model_instance = described_class.new(
        id: 'foo:bar',
        labels: {
          de: 'label DE',
          en: 'label EN'
        }
      )

      expect(model_instance.label).to eq 'label DE'
      expect(model_instance.label(:de)).to eq 'label DE'
      expect(model_instance.label(:en)).to eq 'label EN'
      expect(model_instance.labels).to eq(
        'de' => 'label DE',
        'en' => 'label EN'
      )
    end

    it 'assigns localized description' do
      model_instance = described_class.new(
        id: 'foo:bar',
        descriptions: {
          de: 'description DE',
          en: 'description EN'
        }
      )

      expect(model_instance.description).to eq 'description DE'
      expect(model_instance.description(:de)).to eq 'description DE'
      expect(model_instance.description(:en)).to eq 'description EN'
      expect(model_instance.descriptions).to eq(
        'de' => 'description DE',
        'en' => 'description EN'
      )
    end

    it 'assigns localized hint' do
      model_instance = described_class.new(
        id: 'foo:bar',
        hints: {
          de: 'hint DE',
          en: 'hint EN'
        }
      )

      expect(model_instance.hint).to eq 'hint DE'
      expect(model_instance.hint(:de)).to eq 'hint DE'
      expect(model_instance.hint(:en)).to eq 'hint EN'
      expect(model_instance.hints).to eq(
        'de' => 'hint DE',
        'en' => 'hint EN'
      )
    end
  end
end
