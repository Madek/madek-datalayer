class ApplyCoreVocabTextChanges < ActiveRecord::Migration[4.2]
  class MigrationVocabulary < ActiveRecord::Base
    self.table_name = :vocabularies
  end
  DB_SEEDS ||= YAML.load_file(Rails.root.join('db', 'seeds_and_defaults.yml'))
  .deep_symbolize_keys
  CORE_VOCAB = DB_SEEDS[:MADEK_CORE_VOCABULARY]

  def change
    # re-apply label and description from the otherwise unchangeable core vocab,
    # to import the english translations into newly transalatable fields
    # (2019-04-24)
    execute 'SET session_replication_role = REPLICA;'
    MigrationVocabulary.find(CORE_VOCAB[:id]).update_attributes!(
      CORE_VOCAB.slice(:labels, :descriptions)
        .map { |k, v| [k, v.try(:map) { |k, v| [k, v.try(:strip)] }.to_h] }.to_h)
    ActiveRecord::Base.connection.execute 'SET session_replication_role = DEFAULT;'
  end
end
