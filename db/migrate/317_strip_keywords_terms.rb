class StripKeywordsTerms < ActiveRecord::Migration

  class ::MigrationKeyword < ActiveRecord::Base
    self.table_name = 'keywords'
  end

  def change
    remove_index :keywords, [:meta_key_id, :term]

    strip_regexp = /^(#{Madek::Constants::WHITESPACE_REGEXP_STRING})+|(#{Madek::Constants::WHITESPACE_REGEXP_STRING})+$/

    ::MigrationKeyword.all.each do |keyword|
      if keyword.term =~ strip_regexp
        keyword.update_attributes term: keyword.term.gsub(strip_regexp, '')
      end
    end

    add_index :keywords, [:meta_key_id, :term], unique: true
  end
end
