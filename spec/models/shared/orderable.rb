RSpec.shared_examples 'orderable' do
  let(:parent_scope) { nil }

  it 'responds to move actions' do
    %i(
      move_to_top
      move_up
      move_down
      move_to_bottom
    ).each do |move_method|
      expect(described_class.new).to respond_to(move_method)
    end
  end

  it 'has set parent scope' do
    expect(described_class.parent_scope).to eq parent_scope
  end
end
