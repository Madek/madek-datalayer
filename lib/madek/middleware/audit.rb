require 'active_record'

module Madek
  module Middleware
    class Audit
      # Raised instead of letting a poisoned transaction reach COMMIT. See
      # the NOTE below `Audit#call` for why that COMMIT would otherwise
      # silently succeed as a ROLLBACK.
      class TransactionAbortedError < StandardError
        def initialize(msg = 'DB transaction was aborted; refusing to silently commit-as-rollback')
          super
        end
      end

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
              # NOTE: When one COMMITs an aborted transaction, PG silently issues a ROLLBACK.
              # It responds with ROLLBACK but with PGRES_COMMAND_OK (not an error).
              # The pg gem doesn't raise. Rails doesn't raise.
              # So: if the connection is still aborted here (e.g. the app code
              # caught a DB-level error itself and never re-raised, nor healed
              # it), raise ourselves rather than letting this transaction
              # block exit normally and attempt that ambiguous COMMIT. This
              # turns a would-be silent, misleading 200/302 (whose underlying
              # writes were actually rolled back) into a proper 500, handled
              # by the rescue below like any other error.
              raise TransactionAbortedError if transaction_aborted?
            end
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

      def transaction_aborted?
        connection = db_conn
        connection.transaction_open? &&
          connection.raw_connection.transaction_status == PG::PQTRANS_INERROR
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
