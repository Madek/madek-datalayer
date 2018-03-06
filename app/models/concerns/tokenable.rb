module Concerns
  module Tokenable
    extend ActiveSupport::Concern
    require 'base32/crockford'
    require 'base64'
    require 'digest'

    included do
      attr_accessor :token

      before_save do
        self.token ||= Base32::Crockford.encode(
          SecureRandom.random_number(2**160)) unless persisted?
        self.token_part ||= token.first(5)
        self.token_hash ||= Base64.strict_encode64(
          Digest::SHA256.digest(token))
      end

      belongs_to :user
    end

    class_methods do
      def find_by_token(token_param)
        find_by(
          'token_hash = ? AND revoked = ? AND expires_at > ?',
          Base64.strict_encode64(Digest::SHA256.digest(token_param)),
          false,
          Time.current
        )
      end
    end
  end
end
