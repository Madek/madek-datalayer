class XmpNamespace < ApplicationRecord
  include LocalizedFields

  has_many :xmp_properties, -> { order(:position, :name) }, dependent: :destroy

  localize_fields :labels, :descriptions

  validates :prefix, presence: true, uniqueness: true,
                     format: { with: /\A[A-Za-z_][A-Za-z0-9_-]*\z/ }
  validates :uri, presence: true, uniqueness: true,
                  format: { with: /[\/#]\z/, message: "must end with '/' or '#'" }

  scope :managed, -> { where(is_managed: true) }
  scope :sorted, -> { order(:prefix) }

  def to_s
    prefix
  end
end
