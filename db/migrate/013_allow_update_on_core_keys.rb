class AllowUpdateOnCoreKeys < ActiveRecord::Migration[6.1]
  def up
    dir = Pathname.new(__FILE__).dirname
    execute IO.read(dir.join("013_allow_update_on_core_keys.sql"))
  end
end
