class RemoveBetaTesterGroupNewBrowse < ActiveRecord::Migration[4.2]

  def change
    # the id is UUIDTools::UUID.sha1_create(Madek::Constants::MADEK_UUID_NS, "beta_test_new_browse").to_s
    execute "DELETE FROM groups WHERE id='1b7416e5-daff-5e4b-b97b-021bef493c03'"
  end
end
