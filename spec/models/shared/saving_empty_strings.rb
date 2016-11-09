RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_ensures, 'ensures'
end

RSpec.shared_examples 'saving empty strings' do
  it 'saves empty label' do
    expect(model.update!(label: '')).to eq true
  end

  it 'saves empty description' do
    expect(model.update!(description: '')).to eq true
  end

  it 'saves empty hint' do
    expect(model.update!(hint: '')).to eq true
  end
end
