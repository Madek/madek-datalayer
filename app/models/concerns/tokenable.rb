module Tokenable
  extend ActiveSupport::Concern
  require 'base32/crockford'
  require 'base64'
  require 'digest'

  included do
    attr_accessor :token

    before_create do
      self.token = Base32::Crockford.encode(
        SecureRandom.random_number(2**160)
      )
      self.token_part = token.first(5)
      self.token_hash = self.class.encode_as_token_hash(token)
    end

    belongs_to :user
  end

  class_methods do
    def encode_as_token_hash(token)
      Base64.strict_encode64(
        Digest::SHA256.digest(token)
      )
    end
  end
end
