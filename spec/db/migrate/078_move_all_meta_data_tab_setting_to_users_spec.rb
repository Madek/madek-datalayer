require 'spec_helper'
require Rails.root.join(
  'db/migrate/078_move_all_meta_data_tab_setting_to_users.rb').to_s

describe MoveAllMetaDataTabSettingToUsers do
  let(:migration) { described_class.new }
  let(:connection) { ActiveRecord::Base.connection }
  let(:group_name) { described_class::GROUP_NAME }

  def column_exists?
    connection.column_exists?(:app_settings, :edit_meta_data_power_users_group_id)
  end

  def preference_enabled?(user)
    user.reload.show_all_data_tab_in_edit_mode?
  end

  def ensure_app_setting!
    AppSetting.reset_column_information
    AppSetting.first || create(:app_setting)
  end

  def set_legacy_group_id(group_id)
    ensure_app_setting!
    connection.execute(<<~SQL)
      UPDATE app_settings
      SET edit_meta_data_power_users_group_id = #{connection.quote(group_id)}
    SQL
  end

  def configured_group_id
    connection.select_value(<<~SQL)
      SELECT edit_meta_data_power_users_group_id
      FROM app_settings
      ORDER BY id
      LIMIT 1
    SQL
  end

  def prepare_pre_migration_schema!
    migration.down unless column_exists?
    ensure_app_setting!
  end

  before do
    prepare_pre_migration_schema!
  end

  it 'enables the preference for configured-group members and dissolves the group' do
    group = create(:group, name: group_name)
    member = create(:user, settings: { 'unrelated' => 'kept' })
    outsider = create(:user)
    group.users << member

    delegation = create(:delegation)
    connection.execute(<<~SQL)
      INSERT INTO delegations_groups (delegation_id, group_id)
      VALUES (#{connection.quote(delegation.id)}, #{connection.quote(group.id)})
    SQL

    set_legacy_group_id(group.id)
    expect(configured_group_id).to eq group.id

    migration.up
    AppSetting.reset_column_information

    expect(column_exists?).to be false
    expect(Group.exists?(group.id)).to be false
    expect(Group.where(name: group_name)).to be_empty
    expect(preference_enabled?(member)).to be true
    expect(member.reload.settings).to include(
      'show_all_data_tab_in_edit_mode' => true,
      'unrelated' => 'kept')
    expect(preference_enabled?(outsider)).to be false
  end

  it 'enables the preference for all users when no group was configured' do
    named_group = create(:group, name: group_name)
    user = create(:user, settings: {})
    set_legacy_group_id(nil)

    migration.up
    AppSetting.reset_column_information

    expect(column_exists?).to be false
    expect(Group.exists?(named_group.id)).to be false
    expect(preference_enabled?(user)).to be true
  end

  it 'normalizes non-object settings while enabling the preference' do
    group = create(:group, name: group_name)
    user = create(:user)
    connection.execute(<<~SQL)
      UPDATE users
      SET settings = '[]'::jsonb
      WHERE id = #{connection.quote(user.id)}
    SQL
    group.users << user
    set_legacy_group_id(group.id)

    migration.up

    expect(preference_enabled?(user)).to be true
    expect(user.reload.settings).to eq(
      'show_all_data_tab_in_edit_mode' => true)
  end

  it 'restores the legacy column on down without restoring dissolved groups' do
    group = create(:group, name: group_name)
    set_legacy_group_id(group.id)

    migration.up
    expect(column_exists?).to be false
    expect(Group.exists?(group.id)).to be false

    migration.down
    AppSetting.reset_column_information

    expect(column_exists?).to be true
    expect(Group.exists?(group.id)).to be false
    expect(
      connection.select_value(<<~SQL)
        SELECT edit_meta_data_power_users_group_id
        FROM app_settings
        ORDER BY id
        LIMIT 1
      SQL
    ).to be_nil
  end
end
