require 'digest' 

module Concerns
  module MadekCookieSession
    extend ActiveSupport::Concern

    COOKIE_NAME = Madek::Constants::MADEK_SESSION_COOKIE_NAME

    def set_madek_session(user, auth_system, remember = false)
      @session = UserSession.create!(
        user: user, 
        auth_system: auth_system,
        meta_data: {http_user_agent: request.env["HTTP_USER_AGENT"],
                    remote_addr: request.env["REMOTE_ADDR"]}
      )
      cookies[COOKIE_NAME] = {
        expires: remember ? auth_system.session_max_lifetime_hours.hours.from_now : nil,
        value: @session.token}
      user.update! last_signed_in_at: Time.zone.now
      users_group = AuthenticationGroup.find_or_initialize_by \
        id: Madek::Constants::SIGNED_IN_USERS_GROUP_ID
      users_group.name ||= 'Signed-in Users'
      users_group.save! unless users_group.persisted?
      users_group.users << user unless users_group.users.include?(user)
    end

    def destroy_madek_session
      cookies.delete COOKIE_NAME
    end

    def validate_services_session_cookie_and_get_user
      begin
        @session = 
         UserSession.joins(
         <<-SQL.strip_heredoc
           INNER JOIN auth_systems ON user_sessions.auth_system_id = auth_systems.id
           AND (user_sessions.created_at 
            + auth_systems.session_max_lifetime_hours * interval '1 hour') > now()
         SQL
           ).find_by(
             ["token_hash = ?", 
              Base64.strict_encode64(Digest::SHA256.digest(session_cookie))])
        @session || raise(StandardError, 'No valid user_session found')
        @session.user
      rescue Exception => e
        Rails.logger.warn e
        cookies.delete COOKIE_NAME
        nil
      end
    end

    def session_cookie
      cookies[COOKIE_NAME] || \
        raise(StandardError, 'Session cookie not found.')
    end

  end

end
