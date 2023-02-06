require 'spec_helper'
require 'spec_helper_no_tx'
require_relative 'shared/previous_ids'

describe Group do

  describe 'with few users' do

    before :each do
      PgTasks.truncate_tables
      @group = FactoryBot.create(:group)
      5.times do
        @group.users << FactoryBot.create(:user)
      end
    end

    it 'deleting all users deletes the group' do
      expect(Group.find_by id: @group.id).to be
      expect(@group.users.count).to be >= 1
      @group.users.delete_all
      expect(Group.find_by id: @group.id).not_to be
    end

  end

  describe 'creating an empty one' do

    before :each do
      PgTasks.truncate_tables
    end

    it 'will be not be auto-deleted' do
      @group = FactoryBot.create(:group)
      expect(Group.find_by id: @group.id).to be
    end
  end

  describe '#merge_to' do
    let(:group) { create(:group) }
    let(:receiver) { create(:group) }

    it 'deletes group' do
      expect(group).to receive(:destroy!)

      group.merge_to(receiver)
    end

    it 'remembers previous id' do
      expect { group.merge_to(receiver) }.to change {
        PreviousIds::PreviousGroupId
          .where(previous_id: group.id, group_id: receiver.id)
          .count
      }.by(1)
    end
  end

  include_examples 'previous ids'
end
