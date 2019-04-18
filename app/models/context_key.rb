class ContextKey < ApplicationRecord
  include Concerns::Orderable
  include Concerns::LocalizedFields

  belongs_to :context, foreign_key: :context_id
  belongs_to :meta_key

  enable_ordering skip_default_scope: true, parent_scope: :context
  localize_fields :labels, :descriptions, :hints
end
