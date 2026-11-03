class IoMapping < ApplicationRecord
  include IoMappings::Filters

  belongs_to :io_interface
  belongs_to :meta_key
  belongs_to :xmp_property, optional: true

  validate :key_map_xor_xmp_property

  # `key_map` may hold several comma-separated keys
  def exiftool_keys
    if xmp_property
      [xmp_property.exiftool_key]
    else
      key_map.to_s.split(',').map(&:strip).reject(&:empty?)
    end
  end

  private

  def key_map_xor_xmp_property
    if key_map.present? == xmp_property_id.present?
      errors.add(:base, 'Either key map or XMP property must be given')
    end
  end
end
