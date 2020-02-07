module PreviousIds
  class PreviousPersonId < ApplicationRecord
    belongs_to :person
  end
end
