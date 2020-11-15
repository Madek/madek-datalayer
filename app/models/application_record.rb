class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.valid_uuid?(uuid)
    UUIDTools::UUID_REGEXP =~ uuid
  end
end
