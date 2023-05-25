require 'bcrypt'

module Concerns
  module PasswordAuthentication
    extend ActiveSupport::Concern
    included do

      def password= new_pw
        @password = new_pw
        sql= <<-SQL.strip_heredoc
          SELECT crypt(?, gen_salt('bf'))
        SQL
        res = ActiveRecord::Base.connection.execute(
          ApplicationRecord.sanitize_sql([sql, new_pw]))
        self.password_digest = res.first["crypt"]
      end

      def password 
        @password
      end

      def authenticate(pw)
        if self.password_digest
          sql= <<-SQL.strip_heredoc
            SELECT (users.password_digest = crypt(?, users.password_digest)) 
            AS pw_matches FROM users WHERE id = ?
          SQL
          res = ActiveRecord::Base.connection.execute(
            ApplicationRecord.sanitize_sql([sql, pw, self.id]))
          res.first["pw_matches"] && self
        elsif self.password_digest
          crypt_pw = BCrypt::Password.new(self.password_digest)
          (crypt_pw == pw) && self
        else
          false
        end
      end

    end
  end
end
