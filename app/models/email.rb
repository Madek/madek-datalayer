class Email < ApplicationRecord
  belongs_to(:user)
  belongs_to(:delegation)

  def self.dispatch!(user: nil, delegation: nil,
                     to:, from: SmtpSetting.first.default_from_address,
                     subject:, body:)
    Email.create!(user_id: user&.id,
                  delegation_id: delegation&.id,
                  to_address: to,
                  from_address: from,
                  subject: subject,
                  body: body)
  end
end
