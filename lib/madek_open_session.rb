require 'cider_ci/open_session/encryptor'
require 'cider_ci/open_session/signature'

module MadekOpenSession
  module_function

  extend ActiveSupport::Concern

  def build_session_value(user)
    CiderCi::OpenSession::Encryptor.encrypt(
      secret, user_id: user.id, signature: create_user_signature(user),
              issued_at: Time.now.iso8601)
  end

  def validate_not_expired!(session_object)
    issued_at = Time.parse(session_object[:issued_at]) || \
      raise(StandardError, 'Issued_at could not be determined!')
    unless issued_at + 1.weeks > Time.now
      raise(StandardError, 'Session object is expired!')
    end
  end

  def secret
    Rails.application.secrets.secret_key_base || \
      raise(StandardError, 'secret_key_base must be set!')
  end

  def create_user_signature(user)
    CiderCi::OpenSession::Signature.create \
      secret, user.password_digest
  end

  def validate_user_signature!(user, signature)
    CiderCi::OpenSession::Signature.validate! \
      signature, secret, user.password_digest
  end

end
