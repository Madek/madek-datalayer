class MetaDatum < ActiveRecord::Base

  include Concerns::MetaData::Filters
  include Concerns::MetaData::SanitizeValue

  class << self
    def new_with_cast(*args, &block)
      if self < MetaDatum
        new_without_cast(*args, &block)
      else
        raise 'MetaDatum is abstract; instatiate a subclass'
      end
    end
    alias_method_chain :new, :cast
  end

  ########################################

  belongs_to :meta_key
  has_one :vocabulary, through: :meta_key
  belongs_to :created_by, class_name: 'User'

  # NOTE: need to overwrite the default scope, Rails 5 has '#rescope'
  belongs_to :media_entry, -> { where(is_published: [true, false]) }
  belongs_to :collection
  belongs_to :filter_set

  # TODO: create DB constraint for this
  validates_presence_of :created_by, on: :create

  # needed for Pundit#authorize in controllers
  def self.policy_class
    MetaDatumPolicy
  end

  # we need to hook in the create in order to set the join
  # table values with the created_by user (#set_value!)
  def self.create_with_user!(user, attrs)
    value = attrs.delete(:value)
    meta_datum = new attrs.merge(created_by: user)
    meta_datum.set_value!(value, user)
    meta_datum
  end
end
