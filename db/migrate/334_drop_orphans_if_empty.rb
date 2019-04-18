class DropOrphansIfEmpty < ActiveRecord::Migration[4.2]

  class ::MigrationVocabulary < ActiveRecord::Base
    self.table_name = 'vocabularies'
    self.belongs_to :meta_keys
  end


  # NOTE: created in migration #151, we drop it here if its empty/wasnt needed
  def up
    orphan_vocabulary = MigrationVocabulary.find_by(id: 'madek_orphans')
    if orphan_vocabulary && orphan_vocabulary.meta_keys.blank?
      orphan_vocabulary.destroy!
    end
  end
end
