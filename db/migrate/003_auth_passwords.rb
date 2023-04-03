class AuthPasswords < ActiveRecord::Migration[6.0]
  def up
    dir = Pathname.new(__FILE__).dirname
    execute IO.read(dir.join("003_auth_passwords.sql"))
  end
end
