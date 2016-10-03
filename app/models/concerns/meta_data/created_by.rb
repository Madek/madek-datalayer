module Concerns
  module MetaData
    module CreatedBy
      extend ActiveSupport::Concern

      included do
        belongs_to :created_by, class_name: 'User'
        # validates_presence_of :created_by, on: :create
      end
    end
  end
end
