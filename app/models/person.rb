class Person < ActiveRecord::Base
  include Concerns::FindResource
  include Concerns::People::Filters

  self.inheritance_column = false

  default_scope { reorder(:last_name) }

  has_one :user

  has_and_belongs_to_many :meta_data, join_table: :meta_data_people

  validate do
    if [first_name, last_name, pseudonym].all?(&:blank?)
      errors.add(:base,
                 'Either first_name or last_name or pseudonym must have a value!')
    end
  end

  def to_s
    case
    when ((first_name or last_name) and (pseudonym and !pseudonym.try(:empty?)))
      "#{first_name} #{last_name} (#{pseudonym})".strip
    when (first_name or last_name)
      "#{first_name} #{last_name}".strip
    else
      pseudonym.strip
    end
  end
end
