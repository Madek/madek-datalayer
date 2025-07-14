module MetaData
  module SanitizeValue

    def reset_with_sanitized_value!(resources, type, acting_user = nil)
      with_sanitized(resources, acting_user) do |resources|
        if meta_key.can_have_roles?
          reset_resources_people_roles!(resources, acting_user)
        else
          reset_resources!(resources, type, acting_user)
        end
      end
    end

    # `val` can be one of:
    # - string (text / uuid) or hash (for new entity)
    # - an array of strings (uuids) or hashes (for new entities).
    # In the case of uuids or hashes, the corresponding models have to be initialized.
    def with_sanitized(val, acting_user = nil)
      vals = (val.is_a?(Array) ? val : [val])
      sanitized_value = \
        extract_from_array_if_necessary \
          reject_blanks_and_modelify_if_necessary(vals, acting_user)
      raise 'Use safe value via block!' unless block_given?
      yield(sanitized_value)
    end

    private

    def reset_resources!(resources, type, acting_user)
      type_plural = type.pluralize
      assoc = self.send("meta_data_#{type_plural}")
      resources_to_remove = self.send(type_plural) - resources
      resources_to_add = resources - self.send(type_plural)

      # NOTE: Must do this inside a transaction, otherwise the MetaDatum (`self`)
      # will get cascade-deleted if all current resources are removed…
      ActiveRecord::Base.transaction do
        assoc.where(Hash[type, resources_to_remove]).delete_all
        resources_to_add.each do |resource|
          assoc << assoc.name.constantize.new(
            Hash[type, resource, :created_by, acting_user]
          )
        end
      end
      save!
    end

    def reset_resources_people_roles!(person_role_tuples, acting_user)
      # TODO: index
      tuple_set = person_role_tuples.map { |x| [x.first, x.second] }.to_set
      assignments_to_keep = meta_data_people.select do |mdp|
        tuple_set.include?([mdp.person_id, mdp.role])
      end

      assignments_to_remove = meta_data_people - assignments_to_keep
      new_tuples = person_role_tuples - assignments_to_keep.map { |a| [a.person, a.role] }
      
      assignments_to_remove.each(&:destroy)
      new_tuples.each do |person, role|
        meta_data_people << MetaDatum::Person.new(
          person: person,
          role: role,
          position: 0, # todo
          created_by: acting_user
        )
      end
      save!
    end

    def reject_blanks_and_modelify_if_necessary(vals, acting_user)
      vals
        .reject(&:blank?)
        .map { |v| modelify_if_necessary(v, acting_user) }
    end

    def modelify_if_necessary(val, acting_user)
      if self.value.class < ActiveRecord::Associations::CollectionProxy
        is_people = (self.value.klass == MetaDatum::Person)
        assignee_class = is_people ? Person : self.value.klass
        if meta_key.can_have_roles?
          person_id = extract_person_id(val)
          role_id = extract_role_id(val)
          p = modelify(assignee_class, person_id, acting_user)
          r = role_id && modelify(Role, role_id, acting_user)
          [p, r]
        else
          modelify(assignee_class, val, acting_user)
        end
      else
        val
      end
    end

    def modelify(klass, val, acting_user)
      model = klass.find_or_build_resource!(val, self)
      if model.respond_to?(:creator_id)
        model.creator_id = acting_user.id
      end
      model
    end

    def extract_from_array_if_necessary(val)
      need_to_extract_from_array? ? val.first : val
    end

    def need_to_extract_from_array?
      not self.value.class < ActiveRecord::Associations::CollectionProxy
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
end
