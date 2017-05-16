require 'base32/crockford'
require 'base64'
require 'digest'

class ApiToken < ActiveRecord::Base
  belongs_to :user

  attr_accessor :token

  before_save do
    self.token ||= Base32::Crockford.encode(
      SecureRandom.random_number(2**160)) unless self.persisted?
    self.token_part ||= self.token.first(5)
    self.token_hash ||= Base64.strict_encode64(Digest::SHA256.digest(self.token))
  end

end
