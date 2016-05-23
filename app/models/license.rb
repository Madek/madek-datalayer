class License < ActiveRecord::Base
  include Concerns::FindResource
  include Concerns::Licenses::Filters

  def self.find_resource!(val)
    find_by_id(val) or find_by_url!(val)
  end
end
