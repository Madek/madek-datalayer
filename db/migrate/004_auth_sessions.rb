class AuthSessions < ActiveRecord::Migration[6.0]
  def up
    dir = Pathname.new(__FILE__).dirname
    execute IO.read(dir.join("004_auth_systems.sql"))
    execute IO.read(dir.join("004_auth_sessions.sql"))
  end
end
