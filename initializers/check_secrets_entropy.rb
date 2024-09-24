unless Rails.env.development? \
  || Rails.env.test? \
  || ENV['DISABLE_SECRETS_STRENGTH_CHECK'].present?

  unless StrongPassword::StrengthChecker.new.calculate_entropy(Rails.application.secret_key_base.to_s) > 30
    raise 'The entropy of `secret_key_base` is too low.'
  end

end
