require 'spec_helper'

describe RolesList do
  let!(:used_role_1) { create(:role, labels: { en: 'Author', de: 'Autor' }) }
  let!(:used_role_2) { create(:role, labels: { en: 'Co-Author', de: 'Mitautor' }) }
  let!(:unused_role) { create(:role, labels: { en: 'Unused Role', de: 'Unbenutzte Rolle' }) }
  let!(:roles_list) { create(:roles_list, roles: [used_role_1, used_role_2, unused_role]) }
  let!(:meta_key) { create(:meta_key_people_with_roles, roles_list: roles_list) }
  let!(:meta_datum) { create(:meta_datum_people_with_roles,
                             meta_key: meta_key,
                             people_with_roles: [{ person: create(:person), role: used_role_1 },
                                                 { person: create(:person), role: used_role_2 }]) }


  describe 'removal of role from roles list' do
    it 'prevents removing a role from roles_list when role is used in meta_data_people' do
      expect {
        meta_key.roles_list.roles.destroy!
      }.to raise_error(ActiveRecord::StatementInvalid, /Cannot remove role from roles_list/)
    end

    it 'allows removing a role from roles_list when role is not used in meta_data_people' do
      unused_role = create(:role)
      roles_list_role = RolesListsRole.create!(roles_list: roles_list, role: unused_role)

      expect {
        roles_list_role.destroy!
      }.not_to raise_error
    end

    it 'allows removing a role after removing all meta_data_people associations' do
      # Remove the person-role association
      MetaDataPerson.where(
        meta_datum: @meta_datum,
        person: person,
        role: role
      ).destroy_all

      roles_list_role = RolesListsRole.find_by(roles_list: roles_list, role: role)

      expect {
        roles_list_role.destroy!
      }.not_to raise_error
    end
  end

  describe 'prevent_roles_list_removal_from_meta_key_f trigger' do
    it 'prevents changing roles_list_id on meta_key when meta_key has MetaDatum::People records' do
      new_roles_list = RolesList.create!(
        labels: { 'en' => 'New Roles', 'de' => 'Neue Rollen' }
      )

      expect {
        meta_key.update!(roles_list: new_roles_list)
      }.to raise_error(ActiveRecord::StatementInvalid, /Cannot change roles_list for meta_key/)
    end

    it 'allows changing roles_list_id on meta_key when meta_key has no MetaDatum::People records' do
      unused_meta_key = create(:meta_key, meta_datum_object_type: 'MetaDatum::People')

      new_roles_list = RolesList.create!(
        labels: { 'en' => 'New Roles', 'de' => 'Neue Rollen' }
      )

      expect {
        unused_meta_key.update!(roles_list: new_roles_list)
      }.not_to raise_error
    end

    it 'allows changing roles_list_id after removing all MetaDatum::People records' do
      @meta_datum.destroy!

      new_roles_list = RolesList.create!(
        labels: { 'en' => 'New Roles', 'de' => 'Neue Rollen' }
      )

      expect {
        meta_key.update!(roles_list: new_roles_list)
      }.not_to raise_error
    end

    it 'allows setting roles_list_id to nil when no MetaDatum::People records exist' do
      @meta_datum.destroy!

      expect {
        meta_key.update!(roles_list: nil)
      }.not_to raise_error
    end
  end
end
