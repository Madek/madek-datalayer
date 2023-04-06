class AuthSystem < ApplicationRecord
  self.inheritance_column = :_not_existing_column
  has_many :sessions
  has_and_belongs_to_many :users
end
