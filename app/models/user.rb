# user is the system oriented representation of a User

class User < ApplicationRecord

  # include UserModules::Dropbox
  # include UserModules::TextSearch
  # include UserModules::AutoCompletion
  include Concerns::FindResource
  include Concerns::Users::Filters
  include Concerns::Users::Keywords
  include Concerns::Users::ResourcesAssociations

  has_secure_password validations: false

  attr_accessor 'act_as_uberadmin'

  default_scope { reorder(:login) }

  belongs_to :person, -> { where(subtype: 'Person') }
  accepts_nested_attributes_for :person

  has_many :unpublished_media_entries,
           -> { where(is_published: false) },
           foreign_key: :creator_id,
           class_name: 'MediaEntry',
           dependent: :destroy

  has_many :created_media_entries,
           class_name: 'MediaEntry',
           foreign_key: :creator_id

  #############################################################

  has_many :created_custom_urls, class_name: 'CustomUrl', foreign_key: :creator_id
  has_many :updated_custom_urls, class_name: 'CustomUrl', foreign_key: :updator_id

  has_and_belongs_to_many :groups
  has_one :admin, dependent: :destroy
  belongs_to :accepted_usage_terms, class_name: 'UsageTerms'

  #############################################################

  validates_format_of \
    :email,
    with: /@/, message: "The email must contain a '@' sign."

  #############################################################

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  #############################################################

  def admin?
    !admin.nil?
  end

  #############################################################

  def reset_usage_terms
    update!(accepted_usage_terms_id: nil)
  end

  #############################################################

  def can_edit_permissions_for?(resource)
    resource.responsible_user == self or
      resource
        .user_permissions
        .where(user_id: id, edit_permissions: true).exists?
  end
end
