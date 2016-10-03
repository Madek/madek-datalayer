class ConsolidateZhdkInstitutionalGroups < ActiveRecord::Migration

  class ::Person < ActiveRecord::Base
    self.inheritance_column = false
    default_scope { reorder(:last_name) }
    has_one :user
    has_and_belongs_to_many :meta_data, join_table: :meta_data_people
  end

  class ::MetaDatumPerson < ActiveRecord::Base

    self.table_name = :meta_data_people

    # include Concerns::MetaData::CreatedBy

    belongs_to :meta_datum
    belongs_to :person, class_name: '::Person'
  end


  def change

    ::Person.reset_column_information

    ::Person.first

    puts "Before #{Person.where(subtype: 'PeopleInstitutionalGroup').count} PeopleInstitutionalGroups"
    puts "Before #{MetaDatum::People.count} MetaDatum::People"

    ::Person.where(subtype:  'PeopleInstitutionalGroup').where("institutional_id ilike '%.%'") \
      .map(&:institutional_id).map{|iid| iid.split(/\./).first}.uniq.each do |ldap_id_prefix|

      pgs = ::Person.where("subtype = 'PeopleInstitutionalGroup'").where("institutional_id ilike '#{ldap_id_prefix}.%'")

      consolidated_person_group = ::Person.create! \
        subtype: 'PeopleInstitutionalGroup',
        last_name: pgs.first.last_name,
        institutional_id: ldap_id_prefix

      pgs.each do |pg|
        ::MetaDatumPerson.where(person_id: pg.id).each do |mdp|
          execute <<-SQL.strip_heredoc
            UPDATE meta_data_people SET person_id = '#{consolidated_person_group.id}'
              WHERE person_id = '#{mdp.person_id}'
              AND meta_datum_id = '#{mdp.meta_datum_id}'
          SQL
        end
        pg.delete
      end

    end

    puts "After #{Person.where(subtype: 'PeopleInstitutionalGroup').count} PeopleInstitutionalGroups"
    puts "After #{MetaDatum::People.count} MetaDatum::People"

  end
end
