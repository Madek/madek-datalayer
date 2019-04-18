class MetaDatumGroupsToPeople < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper

  # TODO: for now we have a duplication of name in
  # the person and group table; # normalizing this is not so trivial;
  #
  # I still wonder if the whole thing what we are doing here is so smart.  It
  # would be a clear thing if we could remove the pointer from the groups to
  # the peoples table.


  class Person < ActiveRecord::Base
    self.table_name = :people
    has_one :user
  end

  class User < ActiveRecord::Base
  end

  class Group < ActiveRecord::Base
    belongs_to :person
    has_and_belongs_to_many :meta_data,
      join_table: :meta_data_groups,
      association_foreign_key: :meta_datum_id,
      foreign_key: :group_id
  end

  class InstitutionalGroup < Group
    has_and_belongs_to_many :meta_data,
      join_table: :meta_data_groups,
      association_foreign_key: :meta_datum_id,
      foreign_key: :group_id
  end

  class MetaDatum < ActiveRecord::Base
    belongs_to :meta_key
    has_one :vocabulary, through: :meta_key
    belongs_to :created_by, class_name: 'User'
  end

  class MetaDatum::People < MetaDatum
    has_many :meta_data_people, class_name: 'MetaDatum::Person', foreign_key: :meta_datum_id
    has_many :people, through: :meta_data_people
  end

  class MetaDatum::Person < ActiveRecord::Base
    self.table_name = :meta_data_people
    # include Concerns::MetaData::CreatedBy
    belongs_to :meta_datum
    belongs_to :person, class_name: '::Person'
  end

  class MetaDatum::Groups < MetaDatum
    has_many :groups, through: :meta_data_groups
    has_many :meta_data_groups, class_name: 'MetaDatum::Group', foreign_key: :meta_datum_id
  end

  class MetaDatum::Group < ActiveRecord::Base
    self.table_name = :meta_data_groups
    #include Concerns::MetaData::CreatedBy
    belongs_to :meta_datum
    belongs_to :group, class_name: '::Group'
  end




  def change
    ###########################################################################
    ### some name consistency stuff ###########################################
    ###########################################################################

    %w(first_name last_name pseudonym).each do |field|
      execute <<-SQL.strip_heredoc
        -- strip
        UPDATE people SET #{field} = regexp_replace(#{field}, '\\s+', ' ', 'g');

        -- trim
        UPDATE people SET #{field}= regexp_replace(#{field}, '^\\s+|\\s+$', '', 'g');

        -- set to null if blank
        UPDATE people SET #{field}= NULL WHERE #{field} ~ '^\\s*$';

      SQL
    end

    %w(first_name last_name).each do |field|
      execute <<-SQL.strip_heredoc
        ALTER TABLE people
           ADD CONSTRAINT #{field}_is_not_blank CHECK (#{field} !~ '^\\s*$');
      SQL
    end

    ###########################################################################
    ### institutional_id ######################################################
    ###########################################################################
    execute <<-SQL
      ALTER TABLE people ADD COLUMN institutional_id text ;
      ALTER TABLE people
        ADD CONSTRAINT institutional_id_is_not_blank
        CHECK (institutional_id !~ '^\\s*$');
    SQL


    ###########################################################################
    ### normalize pseudonym ###################################################
    ###########################################################################
    execute <<-SQL
      UPDATE people SET pseudonym = NULL WHERE pseudonym ~ '^\\s*$';
      ALTER TABLE people
        ADD CONSTRAINT pseudonym_is_not_blank
        CHECK (pseudonym !~ '^\\s*$');
    SQL


    add_column :groups, :person_id, :uuid

    ::Group.reset_column_information
    ::InstitutionalGroup.reset_column_information
    ::Person.reset_column_information


    ###########################################################################
    ### migrate data ##########################################################
    ###########################################################################

    # execute 'SET session_replication_role = REPLICA;'

    puts "Before #{MetaDatum::Groups.count} MetaDatum::Groups"
    puts "Before #{MetaDatum::People.count} MetaDatum::People"
    puts "before #{MetaDatum::Group.count} MetaDatum::Group (join table)"
    puts "Before #{MetaDatum::Person.count} MetaDatum::Person (join table)"

    ::Group.find_each do |group|
      person= ::Person.create! is_bunch: true, last_name: group.name,
        pseudonym: group.institutional_group_name, institutional_id: group.institutional_group_id
      group.update_attributes person_id: person.id
    end

    add_column :meta_keys, :allowed_people_subtypes, :text, array: true

    ActiveRecord::Base.transaction do
      execute "SET session_replication_role = REPLICA"

      execute <<-SQL
        UPDATE meta_keys
        SET allowed_people_subtypes = ARRAY['Person', 'PeopleGroup']
        WHERE meta_datum_object_type = 'MetaDatum::People';
      SQL

      execute <<-SQL
        UPDATE meta_keys
        SET meta_datum_object_type = 'MetaDatum::People',
            allowed_people_subtypes = ARRAY['PeopleInstitutionalGroup']
        WHERE meta_datum_object_type = 'MetaDatum::Groups';
      SQL

      execute "SET session_replication_role = DEFAULT"
    end

    MetaDatum::Groups.find_each do |mdgs|
      begin
        mdgs_attrs =  mdgs.attributes.with_indifferent_access.except!(:id, :type)

        mdgxs = mdgs.meta_data_groups.map(&:attributes).map(&:with_indifferent_access)
        mdgs.destroy

        mdp = MetaDatum::People.find_or_create_by(mdgs_attrs.except!(:created_by_id))
        mdp.update_attributes!(mdgs_attrs)

        mdgxs.each do |mdg|
          person = Group.find(mdg[:group_id]).person
          MetaDatum::Person.create! meta_datum_id: mdp.id ,person_id: person.id, created_by_id:  mdg[:created_by_id]
        end

      rescue Exception => e
        binding.pry
      end
    end

    puts "After #{MetaDatum::Groups.count} MetaDatum::Groups"
    puts "After #{MetaDatum::People.count} MetaDatum::People"
    puts "After #{MetaDatum::Group.count} MetaDatum::Group (join table)"
    puts "After #{MetaDatum::Person.count} MetaDatum::Person (join table)"

  end
end
