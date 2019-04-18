class DeleteKeywordsWithBlankTerms < ActiveRecord::Migration[4.2]

  class ::MigrationKeyword < ActiveRecord::Base
    self.table_name = 'keywords'
  end

  class ::MigrationMetaDatumKeyword < ActiveRecord::Base
    self.table_name = 'meta_data_keywords'
  end

  def change
    ActiveRecord::Base.transaction do

      ::MigrationKeyword.all.each do |keyword|

        if keyword.term.blank? or keyword.term =~ Madek::Constants::VALUE_WITH_ONLY_WHITESPACE_REGEXP

          ::MigrationMetaDatumKeyword.where(keyword_id: keyword.id).each do |md|
            md.destroy
          end

          keyword.destroy

        end
      end
    end

  end
end
