module LocalizedFields
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :localized_fields

    def localize_fields(*args)
      @localized_fields = []

      args.each do |field|
        begin
          next unless columns_hash.include?(field.to_s)
        rescue ActiveRecord::StatementInvalid
          next
        end

        @localized_fields << field.to_sym

        getter_name = field.to_s.singularize

        if getter_name == field
          #binding.pry
          raise "`getter_name` is same as `field` after singularization. " \
            "This will cause infinite loop. Ensure that `field` is defined in plural form."
        end

        define_method getter_name do |locale = nil|
          send(field)[determine_locale(locale)].presence
        end
      end
    end

    def localized_field?(column)
      @localized_fields.include?(column.to_sym)
    end
  end

  private

  def _assign_attribute(k, v)
    if self.class.localized_fields.map(&:to_s).include?(k)
      values = v.symbolize_keys
      values.each_pair do |locale, value|
        send(k)[locale.to_s] = value.presence
      end
    else
      super
    end
  end

  def determine_locale(locale)
    locale.nil? ? AppSetting.default_locale : locale.to_s
  end
end
