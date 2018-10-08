class PersonWithRoles
  attr_reader :person, :roles

  def initialize(person, roles)
    @person = person
    @roles = roles
  end
end
