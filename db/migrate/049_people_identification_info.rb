class PeopleIdentificationInfo < ActiveRecord::Migration[6.1]
  def change
    add_column(:people, :identification_info, :text)
  end
end
