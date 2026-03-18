require 'active_record'

module Madek
  module Middleware
    class Audit
      def initialize(app)
        @app = app
      end

      HTTP_UNSAFE_METHODS = ["DELETE", "PATCH", "POST", "PUT"]

      def call(env)
        if unsafe_method?(env["REQUEST_METHOD"])
          txid = nil
          response = nil
          user_id = get_user_id(env["HTTP_COOKIE"])

          begin 
            ActiveRecord::Base.transaction do
              txid = get_txid
              response = @app.call(env)
            end
          # NOTE: When one COMMITs an aborted transaction, PG silently issues a ROLLBACK.
          # It responds with ROLLBACK but with PGRES_COMMAND_OK (not an error).
          # The pg gem doesn't raise. Rails doesn't raise.
          # The middleware's rescue block is never entered.
          # Response (200) is returned to the browser.
          rescue => e
            persist_request(txid, env, user_id)
            persist_response(txid, 500)
            raise(e)
          end

          persist_request(txid, env, user_id)
          persist_response(txid, response.first)

          response
        else
          @app.call(env)
        end
      end

      private

      def unsafe_method?(m)
        HTTP_UNSAFE_METHODS.any? { |unsafe_m| unsafe_m.match(/^#{m}$/i) }
      end

      def db_conn
        ActiveRecord::Base.connection
      end

      def get_txid
        db_conn.execute("SELECT txid() AS txid").entries.first['txid']
      end

      def persist_request(txid, env, user_id)
        path = env["REQUEST_PATH"]
        http_uid = env["HTTP_HTTP_UID"]
        method = env["REQUEST_METHOD"].downcase

        c = db_conn
        c.execute <<-SQL
          INSERT INTO audited_requests (txid, http_uid, path, user_id, method)
          VALUES (#{c.quote(txid)}, #{c.quote(http_uid)}, #{c.quote(path)}, #{c.quote(user_id)}, #{c.quote(method)})
        SQL
      end

      def persist_response(txid, status)
        c = db_conn
        c.execute <<-SQL
          INSERT INTO audited_responses (txid, status)
          VALUES (#{c.quote(txid)}, #{c.quote(status)})
        SQL
      end

      def get_session_token(http_cookie = "")
        http_cookie
          .split(";")
          .find { |c| c.match(Madek::Constants::MADEK_SESSION_COOKIE_NAME) }
          .try(:split, "=")
          .try(:second)
      end

      def get_user_id(http_cookie)
        if http_cookie
          token = get_session_token(http_cookie)
          if token
            user_session = UserSession.find_by_token(token)
            user_session.try(&:user).try(&:id)
          end
        end
      end
    end
  end
end
