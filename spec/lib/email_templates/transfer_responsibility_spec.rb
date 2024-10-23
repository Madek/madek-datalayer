require 'spec_helper'

describe 'Email Templates' do

  describe 'transfer_responsibility' do

    context 'summary for user' do
      before(:each) do
        @user = create(:user)
        @d1 = create(:delegation, name: 'Verantwortungsgruppe 1')
        @d2 = create(:delegation, name: 'Verantwortungsgruppe 2')
        @n1 = create(:notification, :transfer_responsibility, user: @user, via_delegation: @d1,
                     data: {
                       resource: {
                         link_def: { href: '/entries/de4f8ab4-5b2b-4170-b21e-b2282f476acc',
                                     label: 'Medieneintrag ABC' }
                       },
                       user: { fullname: 'Max Mustermann' }
                     })
        @n2 = create(:notification, :transfer_responsibility, user: @user, via_delegation: @d2,
                     data: {
                       resource: {
                         link_def: { href: '/entries/1d09fa3b-3e40-4b17-a73f-e8315d2ce3a9',
                                     label: 'Medieneintrag DEF' }
                       },
                       user: { fullname: 'Hans Muster' }
                     })
        @n3 = create(:notification, :transfer_responsibility, user: @user, via_delegation: @d2,
                     data: {
                       resource: {
                         link_def: { href: '/sets/cd75ba05-b140-44ae-ae2d-95fd771a5aba',
                                     label: 'Set GHI' }
                       },
                       user: { fullname: 'Johann Muster' }
                     },
                     created_at: 1.day.ago)
        @n4 = create(:notification, :transfer_responsibility, user: @user, via_delegation: @d2,
                     data: {
                       resource: {
                         link_def: { href: '/entries/532d1b03-6dff-44c7-885e-eb34e9cd4531',
                                     label: 'Medieneintrag JKL' }
                       },
                       user: { fullname: 'Laura Muster' }
                     },
                     created_at: 1.day.ago - 1.hour)
        @n5 = create(:notification, :transfer_responsibility, user: @user,
                     data: {
                       resource: {
                         link_def: { href: '/entries/532d1b03-6dff-44c7-885e-eb34e9cd4531',
                                     label: 'Medieneintrag MNO' }
                       },
                       user: { fullname: 'Maria Muster' }
                     })

        app_setting = AppSetting.first

        @data = { notifications: @user.notifications,
                  site_titles: { de: '|Site Title DE OK|', en: '|Site Title EN OK|' },
                  external_base_url: "https://external.base",
                  my_settings_url: "|My Settings URL OK|",
                  support_email: "|Support Email OK|",
                  provenance_notices: { de: '|Provenance Notice DE OK|', en: '|Provenance Notice EN OK|' },
                  email_frequency: :daily,
                  batch_index: 0 }

        @tmpl_inst = EmailTemplates::TransferResponsibility.new(@data)
      end

      it 'DE works' do
        email_subject = @tmpl_inst.render_summary_email_subject(:de) 
        expect(email_subject)
          .to eq("|Site Title DE OK|: tägliche Zusammenfassung der Verantwortlichkeits-Übertragungen")
        puts "========================================================================================"
        puts email_subject
        puts "========================================================================================"

        email_body = @tmpl_inst.render_summary_email(:de)
        puts email_body
        puts "========================================================================================"
      end

      it 'EN works' do
        email_subject = @tmpl_inst.render_summary_email_subject(:en) 
        expect(email_subject)
          .to eq("|Site Title EN OK|: daily summary of responsibility transfers")
        puts "========================================================================================"
        puts email_subject
        puts "========================================================================================"

        email_body = @tmpl_inst.render_summary_email(:en)
        puts email_body
        puts "========================================================================================"
      end
    end
  end
end
