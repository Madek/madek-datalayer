class ConvertMetaDataTextToComposedUnicodeFormat < ActiveRecord::Migration
  def change
    MetaDatum::Text.find_each do |mdt|
      mdt.update_attributes! string: \
        mdt.string.present? ? mdt.string.unicode_normalize(:nfc) : nil
    end
  end
end
