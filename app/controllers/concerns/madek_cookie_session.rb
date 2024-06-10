require 'digest'
require 'pp'

module Concerns
  module MadekCookieSession
    extend ActiveSupport::Concern

    COOKIE_NAME = Madek::Constants::MADEK_SESSION_COOKIE_NAME

    def token_hash(session_cookie)
      Base64.strict_encode64(Digest::SHA256.digest(session_cookie))
    end

    def notify_if_session_expiring_soon
      if session_cookie and s = get_valid_session(session_cookie)
        expiry_time = s.created_at + s.auth_system.session_max_lifetime_hours.hours

        if DateTime.now + 10.minutes > expiry_time
          flash[:error] = I18n.t(:session_expiring_soon, minutes: 10)
        elsif DateTime.now + 30.minutes > expiry_time
          flash[:warning] = I18n.t(:session_expiring_soon, minutes: 30)
        end
      end
    end

    def set_madek_session(user, auth_system, remember = false)
      @session = UserSession.create!(
        user: user,
        auth_system: auth_system,
        meta_data: { http_user_agent: request.env["HTTP_USER_AGENT"],
                     remote_addr: request.env["REMOTE_ADDR"] }
      )
      cookies[COOKIE_NAME] = {
        expires: remember ? auth_system.session_max_lifetime_hours.hours.from_now : nil,
        value: @session.token }
      user.update! last_signed_in_at: Time.zone.now
      users_group = AuthenticationGroup.find_or_initialize_by \
        id: Madek::Constants::SIGNED_IN_USERS_GROUP_ID
      users_group.name ||= 'Signed-in Users'
      users_group.save! unless users_group.persisted?
      users_group.users << user unless users_group.users.include?(user)
    end

    def destroy_madek_session

      puts ">> destroy_madek_session / session delete"

      puts ">> cookies[COOKIE_NAME]: #{cookies[COOKIE_NAME]}"
      puts ">> token_hash cookies[COOKIE_NAME]: #{token_hash cookies[COOKIE_NAME]}"

      # binding.pry
      UserSession.find_by_token_hash(token_hash cookies[COOKIE_NAME]).try(:destroy!)
      cookies.delete COOKIE_NAME
    end

    def get_valid_session(session_cookie)
      session = UserSession.joins(<<-SQL.strip_heredoc)
        INNER JOIN auth_systems ON user_sessions.auth_system_id = auth_systems.id
        AND (user_sessions.created_at 
          + auth_systems.session_max_lifetime_hours * interval '1 hour') > now()
      SQL
                           .find_by(["token_hash = ?",
                                     Base64.strict_encode64(Digest::SHA256.digest(session_cookie))])
      # binding.pry
      puts ">> get_valid_session  / session=#{session} / session_cookie=#{session_cookie}"

      puts ">> #{session.to_json}"

      session
    end

    def validate_services_session_cookie_and_get_user
      begin
        @session = get_valid_session(session_cookie!)

        if not @session
          puts ">> 1get_valid_session.error / no valid user_session"
          raise(StandardError, 'No valid user_session found')
        elsif not @session.user.activated?
          puts ">> 2get_valid_session.error / user not activated"

          puts ">> 2get_valid_session.error, #{@session.user.to_json}"

          raise(StandartError, 'User is deactivated')
        else
          puts ">> 3get_valid_session / 1before"
          puts ">> 3get_valid_session / 2found #{@session.user}"
          puts ">> 3get_valid_session / 3found #{@session.user.to_json}"

          # >> 3get_valid_session / 3found {"id":"c0bc861e-e8b2-4a27-9303-44e31a3246e6","email":"manuel.radl@zhdk.ch",
          # "login":"mradl","notes":null,"created_at":"2023-10-13T08:47:28.900Z","updated_at":"2024-06-10T09:59:10.950Z",
          # "person_id":"82c44f16-e28c-453d-b719-c9dbd500f20c","institutional_id":"271682","autocomplete":"",
          # "searchable":"Radl Manuel mradl manuel.radl@zhdk.ch","accepted_usage_terms_id":"e3e9300a-b2f4-4293-a9d1-20476a820c8e",
          # "last_signed_in_at":"2024-06-10T09:59:10.986Z","settings":{"layout":"grid","show_filter":true},
          # "institution":"zhdk.ch","active_until":"2297-11-27T23:59:59.000Z","last_name":"Radl","first_name":"Manuel"}


          puts ">> 3get_valid_session / 4after"
          @session.user
        end

      rescue ActiveRecord::StatementInvalid => e
        # binding.pry
        puts ">> get_valid_session.rescue _> NO delete!!! / cause: #{e.message}"
        puts ">> exception #{e}"
        Rails.logger.warn e

        puts ">> Exception occurred:"
        puts ">> Message: #{e.message}"
        puts ">> Backtrace:"
        e.backtrace.each { |line| puts "  #{line}" }
        nil

      rescue Exception => e
        # puts ">> get_valid_session.rescue _> delete!!! / cause: #{e.message}"
        # puts ">> exception #{e}"
        # puts ">> exception.type #{e.class}"
        #
        # puts ">> Exception occurred:"
        # puts ">> Message: #{e.message}"
        # puts ">> Backtrace:"
        # e.backtrace.each { |line| puts "  #{line}" }

        Rails.logger.warn e
        cookies.delete COOKIE_NAME
        nil
      end
    end

    def session_cookie
      puts ">> session_cookie "
      cookies[COOKIE_NAME]
    end

    def session_cookie!
      puts ">> session_cookie! "
      session_cookie || raise(StandardError, 'Session cookie not found.')
    end

  end

end
