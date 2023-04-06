require 'digest'

class UserSession < ApplicationRecord
  include Concerns::Tokenable
  belongs_to :auth_system
end
