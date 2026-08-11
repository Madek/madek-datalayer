class AdminPermission < ApplicationRecord
  LABELS = {
    'api_clients' => 'API Clients',
    'contexts' => 'Contexts',
    'delegations' => 'Delegations',
    'entries' => 'Entries',
    'groups' => 'Groups',
    'io' => 'IO',
    'keywords' => 'Keywords',
    'manage_admin_permissions' => 'Manage Admin Permissions',
    'meta_data' => 'Meta Data',
    'notifications' => 'Notifications',
    'people' => 'People',
    'roles' => 'Roles',
    'sets' => 'Sets',
    'settings' => 'Settings',
    'smtp' => 'SMTP',
    'sql_assistant' => 'SQL Assistant',
    'uberadmin_edit' => 'Uberadmin (Edit)',
    'uberadmin_view' => 'Uberadmin (View)',
    'usage_terms' => 'Usage Terms',
    'users' => 'Users',
    'vocabularies' => 'Vocabularies'
  }.freeze

  KEYS = LABELS.keys.freeze

  WEBAPP_KEYS = %w(uberadmin_view uberadmin_edit).freeze
  ADMIN_WEBAPP_KEYS = (KEYS - WEBAPP_KEYS).freeze

  belongs_to :admin

  validates :permission_key, inclusion: { in: KEYS }
end
