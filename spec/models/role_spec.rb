require 'spec_helper'

describe Role do

  it 'should be producible by a factory' do
    expect { create(:role) }.not_to raise_error
  end

  describe 'Creating with the same labels' do
    context 'for the same meta key' do
      it 'raises error' do
        role = create :role

        expect do
          create(:role, labels: { de: role.label })
        end.to raise_error ActiveRecord::RecordNotUnique
      end
    end
  end

  describe '#merge_to' do
    let(:role) { create(:role) }
    let(:receiver) { create(:role) }

    it 'deletes role' do
      expect(role).to receive(:destroy!)

      role.merge_to(receiver)

      expect { Role.find(id: role.id) }.to raise_error ActiveRecord::RecordNotFound
    end

    context 'with meta_data_people' do
      let!(:meta_key) { create(:meta_key_people_with_roles) }
      let!(:role) { create(:role) }
      let!(:receiver) { create(:role) }
      let!(:person) { create(:person) }

      before do
        meta_key.roles_list.roles << role unless meta_key.roles_list.roles.include?(role)
        meta_key.roles_list.roles << receiver unless meta_key.roles_list.roles.include?(receiver)
      end

      let!(:meta_datum) do
        create(:meta_datum_people_with_roles,
               meta_key: meta_key,
               people_with_roles: [{ person: person, role: role }])
      end
      let!(:meta_datum_person) { meta_datum.meta_data_people.first }

      it 'transfers meta_data_people to receiver when receiver does not have them' do
        expect { role.merge_to(receiver) }
          .to change { receiver.meta_data_people.count }.by(1)
      end

      it 'updates meta_data_person role_id to receiver' do
        role.merge_to(receiver)

        mdp = MetaDatum::Person.find(meta_datum_person.id)
        expect(mdp.role_id).to eq(receiver.id)
      end

      it 'updates meta_data_person created_by_id to receiver creator' do
        role.merge_to(receiver)

        mdp = MetaDatum::Person.find(meta_datum_person.id)
        expect(mdp.created_by_id).to eq(receiver.creator_id)
      end

      context 'when receiver already has the same meta_data' do
        let!(:receiver_meta_datum_person) do
          create(:meta_datum_person,
                 meta_datum: meta_datum,
                 person: create(:person),
                 role: receiver,
                 created_by: create(:user))
        end

        it 'deletes the duplicate meta_data_person' do
          expect { role.merge_to(receiver) }
            .to change { MetaDatum::Person.count }.by(-1)
        end

        it 'keeps receiver meta_data_person' do
          role.merge_to(receiver)

          expect(MetaDatum::Person.exists?(receiver_meta_datum_person.id)).to be true
        end

        it 'removes role meta_data_person' do
          role.merge_to(receiver)

          expect(MetaDatum::Person.exists?(meta_datum_person.id)).to be false
        end
      end
    end

    context 'with roles_lists' do
      let!(:roles_list) { create(:roles_list, roles: [role]) }

      it 'adds receiver to roles_list when not already present' do
        expect { role.merge_to(receiver) }
          .to change { roles_list.reload.roles.include?(receiver) }.from(false).to(true)
      end

      it 'removes role from roles_list' do
        expect { role.merge_to(receiver) }
          .to change { roles_list.reload.roles.include?(role) }.from(true).to(false)
      end

      context 'when receiver is already in the roles_list' do
        before do
          roles_list.roles << receiver
        end

        it 'keeps receiver in roles_list' do
          expect { role.merge_to(receiver) }
            .not_to change { roles_list.reload.roles.include?(receiver) }
        end

        it 'removes role from roles_list' do
          expect { role.merge_to(receiver) }
            .to change { roles_list.reload.roles.include?(role) }.from(true).to(false)
        end

        it 'does not duplicate receiver in roles_list' do
          role.merge_to(receiver)

          expect(roles_list.reload.roles.where(id: receiver.id).count).to eq(1)
        end
      end
    end
  end
end
