Rails.application.reloader.to_prepare do
  Rails.configuration.i18n.available_locales = AppSetting.available_locales
end
