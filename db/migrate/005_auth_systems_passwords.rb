class AuthSystemsPasswords < ActiveRecord::Migration[6.0]
  def up
    dir = Pathname.new(__FILE__).dirname
    execute IO.read(dir.join("005_auth_systems_passwords.sql"))
  end
end
