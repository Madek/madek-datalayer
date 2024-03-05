class Notification < ApplicationRecord
  belongs_to(:user)
  belongs_to(:email, optional: true)
end
