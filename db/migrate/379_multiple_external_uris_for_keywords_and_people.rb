class MultipleExternalUrisForKeywordsAndPeople < ActiveRecord::Migration[4.2]
  class MigrationPeople < ActiveRecord::Base
    self.table_name = :people
  end
  class MigrationKeywords < ActiveRecord::Base
    self.table_name = :keywords
  end

  def change
    add_column :keywords, :external_uris, :string, array: true, default: '{}'
    add_column :people, :external_uris, :string, array: true, default: '{}'

    MigrationKeywords.reset_column_information
    MigrationPeople.reset_column_information

    MigrationKeywords.where('external_uri IS NOT NULL').each {|k| arrayize_uri(k) }
    MigrationPeople.where('external_uri IS NOT NULL').each {|p| arrayize_uri(p) }

    remove_column :keywords, :external_uri
    remove_column :people, :external_uri
  end
end

def arrayize_uri(row)
  uri = row.external_uri.strip.presence
  row.update_attributes!(external_uris: [uri]) if uri
end
