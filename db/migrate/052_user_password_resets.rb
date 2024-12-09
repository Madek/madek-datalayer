class UserPasswordResets < ActiveRecord::Migration[7.2]
  def up
    dir = Pathname.new(__FILE__).dirname
    execute IO.read(dir.join("052_user_password_resets.sql"))
  end
end
