class MetaDatum < ApplicationRecord

  include Concerns::ContextsHelpers
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
    alias_method :new_without_cast, :new
    alias_method :new, :new_with_cast
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
  # validates_presence_of :created_by, on: :create

  # NOTE: could possibly be made as a DB trigger
  validate if: :validate_required_context_key_condition? do
    context_ids = context_ids_for_required_context_keys_validation
    value_to_validate = new_record? ? potential_value_for_new_record : value
    if value_to_validate.blank? \
        and ContextKey.find_by(meta_key_id: meta_key.id,
                               context_id: context_ids,
                               is_required: true)
      errors.add \
        :base,
        "#{I18n.t(:meta_data_blank_value_for_required_meta_key_pre)}" \
        "#{meta_key.id}" \
        "#{I18n.t(:meta_data_blank_value_for_required_meta_key_post)}"
    end
  end

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

  private

  def validate_required_context_key_condition?
    if collection or filter_set
      false # NOTE: disabled till spec is clear
    else
      media_entry and media_entry.is_published?
    end
  end
end
