require 'spec_helper'

describe NotificationCaseUserSetting do

  it 'is allowed only email frequency set allowed in notification_cases' do
    freq = 'immediately'
    expect do
      FactoryBot.create(:notification_case_user_setting, email_frequency: freq)
    end.to raise_error /Invalid email frequency: #{freq}/
  end

end
