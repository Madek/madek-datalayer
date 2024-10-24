require 'spec_helper'

describe Person do

  # Hint: "bound or unbound" is short for "has or has no institutional_id"

  context 'person user consistency (FK not null and valid)' do
    specify 'try to insert user without person' do
      expect do
        u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person: nil, last_name: "aa", first_name: "aa")
        u1.save
      end.to raise_error ActiveRecord::NotNullViolation
    end
    specify 'try to insert user with a non-existing person_id' do
      expect do
        u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person_id: SecureRandom.uuid, last_name: "aa", first_name: "aa")
        u1.save
      end.to raise_error ActiveRecord::InvalidForeignKey
    end
  end

  context 'person user consistency (irt person subtype)' do
    specify 'insert unbound user with unbound person' do
      p1 = FactoryBot.create(:person, institution: 'local', institutional_id: nil)
      u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person: p1)
    end

    specify 'insert unbound user with unbound person (but it is a PeopleGroup)' do
      p1 = FactoryBot.create(:person, institution: 'local', institutional_id: nil, subtype: 'PeopleGroup')
      expect do
        u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person: p1)
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end

    specify 'insert unbound user with unbound person (but it is a PeopleInstitutionalGroup)' do
      p1 = FactoryBot.create(:person, institution: 'local', institutional_id: nil, subtype: 'PeopleInstitutionalGroup')
      expect do
        u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person: p1)
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end

    specify 'insert unbound user with unbound person, then try to modify the person subtype' do
      p1 = FactoryBot.create(:person, institution: 'local', institutional_id: nil)
      u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person: p1)
      expect do
        p1.update subtype: 'PeopleGroup'
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
      expect do
        p1.update subtype: 'PeopleInstitutionalGroup'
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end
  end

  context 'person user consistency (irt institutional id)' do
    specify 'insert unbound user with unbound person' do
      p1 = FactoryBot.create(:person, institution: 'local', institutional_id: nil)
      u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person: p1)
    end

    specify 'insert bound user with bound person' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: 'moma1')
      u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: 'moma1', person: p1)
    end

    specify 'insert bound user + unbound user with bound person' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: 'moma1')
      u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: 'moma1', person: p1)
      u2 = FactoryBot.create(:user, institution: 'moma', institutional_id: nil, person: p1)
      u3 = FactoryBot.create(:user, institution: 'moma', institutional_id: nil, person: p1)
    end

    specify 'try to insert bound user + other bound user with bound person' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: 'moma1')
      u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: 'moma1', person: p1)
      expect do
        u2 = FactoryBot.create(:user, institution: 'moma', institutional_id: 'moma2', person: p1)
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end

    specify 'try to insert bound user with unbound person' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: nil)
      expect do
        u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: 'moma1', person: p1)
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end

    specify 'insert unbound user with unbound person, then bind the person and the user' do
      p1 = FactoryBot.create(:person, institution: 'local', institutional_id: nil)
      u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person: p1)
      p1.update(institutional_id: 'moma1')
      u1.update(institutional_id: 'moma1')
    end

    specify 'insert unbound user with unbound person, then try to bind the user' do
      p1 = FactoryBot.create(:person, institution: 'local', institutional_id: nil)
      u1 = FactoryBot.create(:user, institution: 'local', institutional_id: nil, person: p1)
      expect do
        u1.update(institutional_id: 'moma1')
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end

    specify 'insert bound user with bound person, then unbind the user und the person' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: 'moma1')
      u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: 'moma1', person: p1)
      u1.update institutional_id: nil
      p1.update institutional_id: nil
    end

    specify 'insert bound user with bound person, then unbind the person' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: 'moma1')
      u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: 'moma1', person: p1)
      expect do
        p1.update institutional_id: nil
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end

    specify 'insert bound user with bound person, then try to re-bind the user und the person' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: 'moma1')
      u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: 'moma1', person: p1)
      expect do
        u1.update institutional_id: 'moma2'
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
      expect do
        p1.update institutional_id: 'moma2'
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end

    specify 'insert unbound user with bound person, then consistently bind the user' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: 'moma1')
      u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: nil, person: p1)
      u1.update institutional_id: 'moma1'
    end

    specify 'insert unbound user with bound person, then try to inconsistently bind the user' do
      p1 = FactoryBot.create(:person, institution: 'moma', institutional_id: 'moma1')
      u1 = FactoryBot.create(:user, institution: 'moma', institutional_id: nil, person: p1)
      expect do
        u1.update institutional_id: 'moma2'
      end.to raise_error ActiveRecord::StatementInvalid, /PG::RaiseException/
    end
  end
end
