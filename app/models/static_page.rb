class StaticPage < ApplicationRecord
  include LocalizedFields

  localize_fields :contents
  before_validation :parameterize_name

  def empty_content?
    contents
      .values
      .compact
      .empty?
  end

  private

  def parameterize_name
    self.name = name.try!(:parameterize)
  end
end
