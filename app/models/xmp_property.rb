class XmpProperty < ApplicationRecord
  include LocalizedFields

  VALUE_TYPES = ['Text', 'Integer', 'Boolean', 'Date', 'URI',
                 'Lang Alt', 'bag Text', 'seq Text'].freeze

  belongs_to :xmp_namespace
  has_many :io_mappings, dependent: :restrict_with_error

  localize_fields :labels, :descriptions

  validates :name, presence: true,
                   format: { with: /\A[A-Za-z_][A-Za-z0-9._-]*\z/ },
                   uniqueness: { scope: :xmp_namespace_id, case_sensitive: false }
  validates :value_type, inclusion: { in: VALUE_TYPES }

  def qualified_name
    "#{xmp_namespace.prefix}:#{name}"
  end

  # Tag name as reported by ExifTool with option `-G1`
  def exiftool_key
    "XMP-#{xmp_namespace.prefix}:#{name.upcase_first}"
  end

  def to_s
    qualified_name
  end
end
