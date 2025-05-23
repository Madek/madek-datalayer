class MetaDatum::Roles < MetaDatum

  ATTRIBUTES_FOR_ON_THE_FLY_RESOURCE_CREATION = [:first_name,
                                                 :last_name,
                                                 :pseudonym,
                                                 :subtype]

  has_many :meta_data_roles,
           class_name: 'MetaDatum::Role',
           foreign_key: :meta_datum_id,
           dependent: :delete_all

  has_many :people, through: :meta_data_roles
  has_many :roles, through: :meta_data_roles

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :meta_data_roles

  def value=(people_with_roles)
    meta_data_roles.delete_all

    people_with_roles.each_with_index do |person_with_role, index|
      person = person_with_role.keys.first
      role_id = person_with_role.values.first

      attrs = Hash[:person, person,
                   :role_id, role_id,
                   :position, index]

      meta_data_roles << meta_data_roles.name.constantize.new(attrs)
    end
  end

  def set_value!(roles, created_by_user)
    if roles.delete_if(&:blank?).empty?
      destroy! and return
    end

    ActiveRecord::Base.transaction do
      people_and_roles = [].tap do |result|
        prepare_data(roles).each do |person_with_role|
          person_params = person_with_role.keys.first
          next if person_params.blank?
          person = ::Person.find_or_build_resource!(person_params, self)
          person.save! if person.new_record?

          role_uuid_or_labels = person_with_role.values.first
          if !role_uuid_or_labels
            result << { person => nil }
          else
            role_uuid = begin
                          UUIDTools::UUID.parse(role_uuid_or_labels).to_s
                        rescue
                          labels = { de: role_uuid_or_labels[:term],
                                     en: role_uuid_or_labels[:term] }
                          new_role = ::Role.find_or_create_by!(labels: labels,
                                                               meta_key_id: self.meta_key.id,
                                                               creator_id: created_by_user.id)
                          new_role.id
                        end

            result << { person => role_uuid }
          end
        end
      end

      self.value = people_and_roles

      save!
    end
  end

  def potential_value_for_new_record; end

  def sanitize_attributes_for_on_the_fly_resource_creation(attrs_hash)
    attrs_hash.permit(ATTRIBUTES_FOR_ON_THE_FLY_RESOURCE_CREATION)
  end

  private

  def prepare_data(source)
    source.map do |person_with_role|
      role_id = extract_role_id(person_with_role)
      person_id = extract_person_id(person_with_role)
      { person_id => role_id }
    end
  end

  def extract_person_id(data)
    if data.is_a?(ActionController::Parameters)
      data.fetch('uuid', data)
    else
      data
    end
  end

  def extract_role_id(data)
    if data.is_a?(ActionController::Parameters)
      data['role']
    end
  end

end
