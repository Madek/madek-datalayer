module MetaKeys
  module MetaDatumObjectType
    module Text
      extend ActiveSupport::Concern

      included do
        def can_have_text_type?
          meta_datum_object_type == 'MetaDatum::Text'
        end
      end
    end
  end
end
