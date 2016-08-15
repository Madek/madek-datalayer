require 'spec_helper'
require 'spec_helper_no_tx'

describe Group do

  describe 'with few users' do

    before :each do
      PgTasks.truncate_tables
      @group = FactoryGirl.create(:group)
      5.times do
        @group.users << FactoryGirl.create(:user)
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
      @group = FactoryGirl.create(:group)
      expect(Group.find_by id: @group.id).to be
    end
  end
end
