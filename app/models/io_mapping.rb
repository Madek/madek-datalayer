class IoMapping < ApplicationRecord
  include IoMappings::Filters
  include Orderable

  enable_ordering

  belongs_to :io_interface
  belongs_to :meta_key
end
