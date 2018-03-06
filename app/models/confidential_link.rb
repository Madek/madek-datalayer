class ConfidentialLink < ActiveRecord::Base
  belongs_to :resource, polymorphic: true
  belongs_to :user

  before_save do
    self.token ||= Base32::Crockford.encode(
      SecureRandom.random_number(2**160)) unless persisted?
  end

  class << self
    def find_by_token(token_param)
      cfl = find_by(token: token_param, revoked: false)
      if !cfl || cfl.expires_at.nil? || cfl.expires_at > Time.current
        cfl
      end
    end

    def find_by_token!(token_param)
      if cfl = find_by_token(token_param)
        cfl
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find #{name}"
      end
    end

  end
end
