class PeopleWithRoles
  attr_reader :data

  def initialize(people_and_roles)
    @data = people_and_roles
  end

  def map
    @data.map do |d|
      yield PersonWithRoles.new(d.first, d.last)
    end
  end
end
