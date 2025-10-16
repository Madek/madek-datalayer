class Role < ApplicationRecord

  include Roles::Filters
  include FindResource
  include LocalizedFields

  localize_fields :labels

  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :roles_lists, join_table: 'roles_lists_roles'
  has_many :meta_data_people, class_name: 'MetaDatum::Person', dependent: :nullify
  has_many :meta_data, through: :meta_data_people

  scope :sorted, lambda { |locale = AppSetting.default_locale|
    throw unless AppSetting.available_locales.include?(locale.to_s)
    order(Arel.sql("roles.labels->'#{locale}'"))
  }
  scope :with_usage_count, lambda {
    select('roles.*, count(meta_data_people.id) as usage_count')
      .joins('LEFT OUTER JOIN meta_data_people' \
             ' ON meta_data_people.role_id = roles.id')
      .group('roles.id')
  }

  validate do
    errors.add(:base, "Label can't be blank") if label.blank?
  end

  def to_s
    label
  end

  def usage_count
    meta_data_people.count
  end

  def merge_to(receiver)
    ActiveRecord::Base.transaction do
      self.meta_data.each do |md|
        old_mdp = md.meta_data_people.find_by(role_id: self.id)
        if md.meta_data_people.find_by(role_id: receiver.id)
          old_mdp.destroy!
        else 
          old_mdp.update_columns(
            role_id: receiver.id,
            created_by_id: receiver.creator_id
          )
        end
      end

      # Merge roles_list associations
      roles_lists.each do |roles_list|
        unless roles_list.roles.include?(receiver)
          # Replace self with receiver in the roles_list
          roles_list.roles.delete(self)
          roles_list.roles << receiver
        else
          # Just remove self since receiver is already present
          roles_list.roles.delete(self)
        end
      end

      destroy!
    end
  end
end
