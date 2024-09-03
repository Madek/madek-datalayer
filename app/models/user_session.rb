require 'digest'

class UserSession < ApplicationRecord
  include Tokenable
  belongs_to :auth_system

  def self.find_by_token(token)
    find_by_token_hash(encode_as_token_hash(token))
  end
end
