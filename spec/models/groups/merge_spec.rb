require 'spec_helper'

describe Group do

  context 'merge' do
    it 'elaborate merge including recursion: A -> B, B -> D, C -> D' do
      g1 = FactoryBot.create(:group)
      g2 = FactoryBot.create(:group)
      g3 = FactoryBot.create(:group)
      g4 = FactoryBot.create(:group)
      g1.merge_to(g2)
      g2.merge_to(g4)
      g3.merge_to(g4)
      expect(g4.previous.map(&:previous_id).to_set).to eq [g1.id, g2.id, g3.id].to_set
      expect(Group.find_by_id(g1.id)).not_to be
      expect(Group.find_by_id(g2.id)).not_to be
      expect(Group.find_by_id(g3.id)).not_to be
    end
  end
end

