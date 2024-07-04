require 'base32/crockford'
require 'base64'
require 'digest'

class ApiToken < ApplicationRecord
  include Concerns::Tokenable

  def self.find_by_token(token_param)
    find_by(
      'token_hash = ? AND revoked = ? AND expires_at > ?',
      encode_as_token_hash(token_param),
      false,
      Time.current
    )
  end
end
