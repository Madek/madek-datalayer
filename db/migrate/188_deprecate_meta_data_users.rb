class DeprecateMetaDataUsers < ActiveRecord::Migration[4.2]

  class MetaKey < ActiveRecord::Base
    self.table_name = 'meta_keys'
  end

  class MetaDatum < ActiveRecord::Base
    self.table_name = 'meta_data'
    belongs_to :meta_key
  end

  class MetaDataUsers < ActiveRecord::Base
    self.table_name = 'meta_data_users'
    belongs_to :meta_datum
    belongs_to :user
    belongs_to :created_by, class_name: 'User'
  end

  class MetaDataPeople < ActiveRecord::Base
    self.table_name = 'meta_data_people'
    belongs_to :meta_datum
    belongs_to :person
    belongs_to :created_by, class_name: 'User'
  end

  class Person < ActiveRecord::Base
    self.table_name = 'people'
  end

  class User < ActiveRecord::Base
    self.table_name = 'users'
    belongs_to :person
  end

  def up
    ActiveRecord::Base.transaction do
      execute "SET session_replication_role = REPLICA"

      execute \
        "UPDATE meta_keys " \
        "SET meta_datum_object_type = 'MetaDatum::People' " \
        "WHERE meta_datum_object_type = 'MetaDatum::Users'"

      execute \
        "UPDATE meta_data " \
        "SET type = 'MetaDatum::People' " \
        "WHERE type = 'MetaDatum::Users'"

      MetaDataUsers.reset_column_information
      MetaDataPeople.reset_column_information

      MetaDataUsers.all.each do |md_user|
        MetaDataPeople.create!(meta_datum: md_user.meta_datum,
                               person: md_user.user.person,
                               created_by: md_user.created_by)
      end

      drop_table :meta_data_users

      execute "SET session_replication_role = DEFAULT"
    end
  end
end
