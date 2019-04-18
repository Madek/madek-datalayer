class AddPositionToKeywords < ActiveRecord::Migration[4.2]
  class MigrationMetaKey < ActiveRecord::Base
    self.table_name = :meta_keys
  end

  class MigrationKeyword < ActiveRecord::Base
    self.table_name = :keywords
  end

  def change
    add_column :keywords, :position, :integer
    add_index :keywords, :position

    MigrationKeyword.reset_column_information
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          MigrationMetaKey.where(meta_datum_object_type: 'MetaDatum::Keywords').each do |meta_key|
            keywords = MigrationKeyword.where(meta_key_id: meta_key.id)
            keywords = keywords.order('keywords.term ASC') if meta_key.keywords_alphabetical_order

            keywords.each_with_index do |keyword, i|
              keyword.update_column(:position, i)
            end
          end
        end
      end
    end
  end
end
