class AddAdminCommentToPeople < ActiveRecord::Migration[6.1]

  def change
    add_column(:people, :admin_comment, :text)
  end

end
