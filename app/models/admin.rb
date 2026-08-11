class Admin < ApplicationRecord
  belongs_to :user
  has_many :admin_permissions, dependent: :destroy
  attr_accessor :webapp_session_uberadmin_mode # NOTE: only set per-request!

  def permission_keys
    admin_permissions.pluck(:permission_key)
  end
end
