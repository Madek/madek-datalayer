class XmpSidecar < ApplicationRecord
  belongs_to :media_entry
  belongs_to :user, optional: true
end
