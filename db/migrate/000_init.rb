class Init < ActiveRecord::Migration[6.1]
  def up
    dir = Pathname.new(__FILE__).dirname
    execute  IO.read(dir.join("000_init.sql"))
    enable_extension 'pg_trgm'
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'
  end
end
