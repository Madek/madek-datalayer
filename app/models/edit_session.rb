class EditSession < ApplicationRecord

  belongs_to :user
  belongs_to :media_entry
  belongs_to :collection

  validates_presence_of :user

  validate :exactly_one_associated_resource_type

  default_scope { order('edit_sessions.created_at DESC') }

  def exactly_one_associated_resource_type
    return if media_entry or collection
    errors.add :base,
               'Edit session must belong to either media entry \
               or collection .'
  end

end
