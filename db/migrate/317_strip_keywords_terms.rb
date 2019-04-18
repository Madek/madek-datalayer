class StripKeywordsTerms < ActiveRecord::Migration[4.2]

  class ::MigrationKeyword < ActiveRecord::Base
    self.table_name = 'keywords'
  end

  class ::MigrationMetaDatumKeyword < ActiveRecord::Base
    self.table_name = 'meta_data_keywords'
  end

  def change
    ActiveRecord::Base.transaction do
      execute "SET session_replication_role = REPLICA"

      ::MigrationKeyword.all.each do |keyword|
        if keyword.term =~ Madek::Constants::TRIM_WHITESPACE_REGEXP
          new_term = keyword.term.gsub(Madek::Constants::TRIM_WHITESPACE_REGEXP, '')

          # if there is already another keyword for the same meta_key and stripped term
          if other_keyword = ::MigrationKeyword.find_by(meta_key_id: keyword.meta_key_id, term: new_term)
            # change all rows in meta_data_keywords to point keyword_id to the other keyword
            ::MigrationMetaDatumKeyword.where(keyword_id: keyword.id).each do |md|
              old_created_at = md.created_at
              old_updated_at = md.updated_at
              # make a copy of the meta_datum
              new_md = md.dup
              new_md.created_at = old_created_at
              new_md.updated_at = old_updated_at
              # destroy the meta_datum for the stripped keyword
              md.destroy
              # point keyword_id for the new meta_datum to the other keyword
              new_md.keyword_id = other_keyword.id
              # create new meta_datum_keyword only if there is not one already for the same keyword and meta_datum
              unless ::MigrationMetaDatumKeyword.find_by(keyword_id: new_md.keyword_id, meta_datum_id: new_md.meta_datum_id)
                new_md.save
                raise unless new_md.reload.created_at == old_created_at
                raise unless new_md.reload.updated_at == old_updated_at
              end
            end

            # delete the keyword
            keyword.destroy

          # else simply update term to the new stripped value
          else
            keyword.update_attributes term: new_term
          end
        end
      end
    end

    execute "SET session_replication_role = DEFAULT"
  end
end
