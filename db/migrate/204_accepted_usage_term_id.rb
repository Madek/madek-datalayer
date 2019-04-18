class AcceptedUsageTermId < ActiveRecord::Migration[4.2]
  include Madek::MigrationHelper
  include Madek::MediaResourceMigrationModels

  def change
    add_column :users, :accepted_usage_terms_id, :uuid
    ::MigrationUser.reset_column_information

    execute "SET session_replication_role = REPLICA"

    # refering to updated_at, because for some reason the usage
    # terms don't have a created_at and get the default one (`now()`)
    # in a previous migration
    usage_terms = ::MigrationUsageTerms.all.sort { |ut1, ut2| ut2.updated_at <=> ut1.updated_at }

    ::MigrationUser.find_each do |user|

      # only if some usage term version ever accepted
      if user.usage_terms_accepted_at

        accepted_usage_term = usage_terms.detect do |usage_term|
          user.usage_terms_accepted_at >= usage_term.updated_at
        end

        if accepted_usage_term
          user.accepted_usage_terms_id = accepted_usage_term.id
        else
          # if for some reason no corresponding usage term found
          # then nullify the wrong usage term reference
          user.accepted_usage_terms_id = nil
        end

        user.save!
      end

    end

    execute "SET session_replication_role = DEFAULT"

    remove_column :users, :usage_terms_accepted_at
  end
end
