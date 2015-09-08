unless Rails.env.development? ||  Rails.env.test?

  unless StrongPassword::StrengthChecker.new(
    Rails.application.secrets.secret_key_base.to_s
  ).calculate_entropy > 30

    raise 'The entropy of `secret_key_base` is too low.'
  end

  unless StrongPassword::StrengthChecker.new(
    Settings.madek_master_secret.to_s
  ).calculate_entropy > 30

   raise 'The entropy of `madek_master_secret` is too low.'
  end

end
