class UpdateZhdkLdapData < ActiveRecord::Migration[4.2]

  def domain_name
    `hostname -d`.strip rescue ''
  end

  def change
    # applied and afterwards disabled
    if (false && ( %w(nx-18122 madek-prod madek-test madek-test-blank madek-staging).include?(`hostname`.strip) \
                  && ['', 'madek.zhdk.ch'].include?(domain_name)))

      ::InstitutionalGroup.reset_column_information
      InstitutionalGroup.first

      data = JSON.parse(IO.read(
        Madek::Constants::DATALAYER_ROOT_DIR.join("db","ldap_2016-10-24.json")
      )).map(&:with_indifferent_access)

      ### deleting db permission groups which have been removed from LDAP #####

      new_ids = Set.new(data.map &->(_) {_[:institutional_group_id]})
      inst_group_ids = Set.new(InstitutionalGroup.all.map(&:institutional_group_id))

      (inst_group_ids - new_ids).each do |id|
        igroup = InstitutionalGroup.find_by(institutional_group_id: id)
        puts "Deleting InstitutionalGroup #{igroup} is being removed."
        igroup.destroy
      end

      ### creating or updating institutional permission group ##################
      data.each do |lgroup|
        ig = InstitutionalGroup.find_or_initialize_by(
          institutional_group_id: lgroup[:institutional_group_id])
        ig.assign_attributes lgroup
        case
        when ig.new_record?
          puts "Creating new `InstitutionalGroup` #{lgroup}"
        when ig.changed?
          puts "Updating `InstitutionalGroup` from #{lgroup}, changes: #{ig.changes}"
        end
        ig.save!
      end

      ### creating or updating PeopleInstitutionalGroup ########################
      data.select{|g| g[:institutional_group_id] =~ /\.alle$/  }.each do |lgroup|
        pig = Person.find_or_initialize_by(
          institutional_id: lgroup[:institutional_group_id],
          subtype: 'PeopleInstitutionalGroup')
        pig.last_name = lgroup[:name]
        pig.pseudonym  = lgroup[:institutional_group_name]
        case
        when pig.new_record?
          puts "Creating `PeopleInstitutionalGroup` #{lgroup} => #{pig}"
        when pig.changed?
          puts "Updating `PeopleInstitutionalGroup` from #{lgroup}, changes: #{pig.changes}"
        end
        pig.save!
      end
    end
  end
end
