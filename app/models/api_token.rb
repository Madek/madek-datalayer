require 'base32/crockford'
require 'base64'
require 'digest'

class ApiToken < ActiveRecord::Base
  belongs_to :user

  attr_accessor :secret

  before_save do
    self.secret ||= Base32::Crockford.encode(
      SecureRandom.random_number(2**160)) unless self.persisted?
    self.id ||= Base64.strict_encode64(Digest::SHA256.digest(secret))
  end

end
