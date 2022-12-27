unless Rails.env.development? \
  || Rails.env.test? \
  || ENV['DISABLE_SECRETS_STRENGTH_CHECK'].present?

  unless StrongPassword::StrengthChecker.new.calculate_entropy(Rails.application.secrets.secret_key_base.to_s) > 30
    raise 'The entropy of `secret_key_base` is too low.'
  end

  unless StrongPassword::StrengthChecker.new.calculate_entropy(Settings.madek_master_secret.to_s) > 30
   raise 'The entropy of `madek_master_secret` is too low.'
  end

end
