class UsersActiveUntil < ActiveRecord::Migration[6.1]
  class MigrationUser < ActiveRecord::Base
    self.table_name = 'users'
  end
  class MigrationAppSetting < ActiveRecord::Base
    self.table_name = 'app_settings'
  end

  def up
    add_column(:users, :active_until, :timestamptz,
               null: false,
               default: -> { "current_date + interval '100000 day - 1 second'" })

    # safe??
    ActiveRecord::Base.connection.execute \
      'SET session_replication_role = REPLICA;'

    time_zone = MigrationAppSetting.first.try(:time_zone) || 'UTC'
    now = Time.now.in_time_zone(time_zone)
    active_until = (now - 1.day).end_of_day

    MigrationUser
      .where(is_deactivated: true)
      .update_all(active_until: active_until)

    ActiveRecord::Base.connection.execute \
      'SET session_replication_role = DEFAULT;'

    remove_column(:users, :is_deactivated)

    add_column(:app_settings, :users_active_until_ui_default, :integer, default: 99999)
  end

  def down
    add_column(:users, :is_deactivated, :boolean, default: false)

    # safe??
    ActiveRecord::Base.connection.execute  \
      'SET session_replication_role = REPLICA;'
    MigrationUser
      .where('now() > active_until')
      .update_all(is_deactivated: true)
    ActiveRecord::Base.connection.execute  \
      'SET session_replication_role = DEFAULT;'

    remove_column(:users, :active_until)

    remove_column(:app_settings, :users_active_until_ui_default)
  end
end

