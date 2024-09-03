module MediaFiles
  module Sorters
    extend ActiveSupport::Concern

    included do
      scope :sort_by_uploader, lambda { |dir|
        order("people.first_name #{dir}, people.last_name #{dir}")
      }
    end
  end
end
