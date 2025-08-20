class MetaDatum::People < MetaDatum

  has_many :meta_data_people,
           ->() { unscope(:order).order(
              'meta_data_people.position ASC', :id
           )},
           class_name: 'MetaDatum::Person',
           foreign_key: :meta_datum_id

  has_many :people,
           ->() { unscope(:order).order(
              'meta_data_people.position ASC', :last_name, :first_name, :id
           )},
           through: :meta_data_people
  has_many :roles, through: :meta_data_people

  def to_s
    people.map(&:to_s).join('; ')
  end

  alias_method :value, :meta_data_people

  def potential_value_for_new_record
    meta_data_people.map(&:person)
  end

  def set_value!(vals, acting_user)
    people_and_roles = vals.reject(&:blank?)
      .map do |val| 
        person_id = extract_person_id(val)        
        role_uuid_or_labels = extract_role_id(val)
        { 
          person: find_or_create_person!(person_id, acting_user),
          role: (find_or_create_role!(role_uuid_or_labels, acting_user) unless role_uuid_or_labels.nil?)
        }
      end
    reset_resources_people_roles!(people_and_roles, acting_user)
  end

  def sanitize_attributes_for_on_the_fly_resource_creation(attrs_hash)
    attrs_hash.permit([:first_name,
                       :last_name,
                       :pseudonym,
                       :subtype])
  end

  private

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

  def find_or_create_person!(val, acting_user)
    person = ::Person.find_or_build_resource!(val, self)
    if person.new_record?
      person.creator_id = acting_user.id
      person.save!
    end
    person
  end
  
  def find_or_create_role!(role_uuid_or_labels, acting_user)
    # role_uuid_or_labels: UUID or `{:term: "My new role"}`
    role_id = UUIDTools::UUID.parse(role_uuid_or_labels).to_s rescue nil
    if role_id.nil? && role_uuid_or_labels[:term]
      term = role_uuid_or_labels[:term]
      labels = { de: role_uuid_or_labels[:term], en: role_uuid_or_labels[:term] }
      role = Role.where(labels: labels).distinct.first
      if !role
        # create a new role
        role = Role.new(labels: labels,
                        roles_lists: [self.meta_key.roles_list],
                        creator_id: acting_user.id)
        role.save!
      else
        # make sure the role is in the role list
        unless self.meta_key.roles_list.roles.include?(role)
          self.meta_key.roles_list.roles << role
          self.meta_key.roles_list.save!
        end
      end
    else
      role = Role.find(role_id)
    end
    role
  end

  def reset_resources_people_roles!(people_and_roles, acting_user)
    # people_and_roles: array of `{person: Person, role: Role-or-nil}`

    assignments_to_keep = meta_data_people.select do |a|
      people_and_roles.find do |person_and_role|
        a.person == person_and_role[:person] && a.role == person_and_role[:role]
      end
    end
    assignments_to_remove = meta_data_people - assignments_to_keep

    ActiveRecord::Base.transaction do
      assignments_to_remove.each(&:destroy)
      people_and_roles.each_with_index do |person_and_role, index|
        assignment = assignments_to_keep.find do |a| 
          a.person == person_and_role[:person] && a.role == person_and_role[:role]
        end
        if assignment
          assignment.position = index
          assignment.save! if assignment.changed?
        else
          assignment = MetaDatum::Person.new(
            meta_datum: self,
            person: person_and_role[:person],
            role: person_and_role[:role],
            created_by: acting_user,
            position: index
          )
          assignment.save!
        end
      end
    end
  end

end
