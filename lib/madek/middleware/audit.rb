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

          ActiveRecord::Base.transaction do
            txid = get_txid
            response = @app.call(env)
          end

          persist_request(txid, env, user_id)
          persist_response(txid, response)

          response
        else
          @app.call(env)
        end
      end

      private

      def unsafe_method?(m)
        HTTP_UNSAFE_METHODS.include?(m)
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

        db_conn.execute <<-SQL
          INSERT INTO audited_requests (
            txid,
            http_uid,
            path,
            user_id,
            method
          )
          VALUES (
            '#{txid}',
            #{http_uid.presence ? "'#{http_uid}'" : "NULL"},
            #{path.presence ? "'#{path}'" : "NULL"},
            #{user_id.presence ? "'#{user_id}'" : "NULL"},
            #{method.presence ? "'#{method}'" : "NULL"}
          )
        SQL
      end

      def persist_response(txid, (status))
        db_conn.execute <<-SQL
          INSERT INTO audited_responses (txid, status)
          VALUES ('#{txid}', '#{status}')
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
