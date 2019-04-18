class FinalizeMetaDatumGroupsToPeople < ActiveRecord::Migration[4.2]

  def change

    ### reset some constraints ################################################

    types = [
      'MetaDatum::Keywords',
      'MetaDatum::Licenses',
      'MetaDatum::People',
      'MetaDatum::Text',
      'MetaDatum::Text',
      'MetaDatum::TextDate',
      'MetaDatum::Users',
      'MetaDatum::Vocables',
    ]

    execute <<-SQL.strip_heredoc
      ALTER TABLE meta_data DROP CONSTRAINT check_valid_type;
    SQL

    execute <<-SQL.strip_heredoc
      ALTER TABLE meta_data ADD CONSTRAINT check_valid_type CHECK
          (type IN (#{types.uniq.map{|s|"'#{s}'"}.join(', ')}));
    SQL

    %w( meta_data meta_data_keywords meta_data_licenses meta_data_people).each do |table|

      execute <<-SQL.strip_heredoc
        CREATE OR REPLACE FUNCTION check_#{table}_created_by()
        RETURNS TRIGGER AS $$
        BEGIN
          IF NEW.created_by_id IS NULL THEN
            RAISE EXCEPTION 'created_by in table #{table} may not be null';
          END IF;
          RETURN NEW;
        END;
        $$ language 'plpgsql';

        CREATE TRIGGER trigger_check_#{table}_created_by
        AFTER INSERT
        ON #{table}
        FOR EACH ROW
        EXECUTE PROCEDURE check_#{table}_created_by()
      SQL

    end


  end
end
