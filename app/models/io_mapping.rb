class IoMapping < ApplicationRecord
  include Concerns::IoMappings::Filters

  belongs_to :io_interface
  belongs_to :meta_key
end
