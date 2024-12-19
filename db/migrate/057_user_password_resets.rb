class UserPasswordResets < ActiveRecord::Migration[7.2]
  def up
    dir = Pathname.new(__FILE__).dirname
    execute IO.read(dir.join("057_user_password_resets.sql"))

    add_column(:users, :password_sign_in_enabled, :boolean,
               default: false, null: false)
  end
end
