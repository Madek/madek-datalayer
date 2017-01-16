class Admin < ActiveRecord::Base
  belongs_to :user
  attr_accessor :webapp_session_uberadmin_mode # NOTE: only set per-request!
end
