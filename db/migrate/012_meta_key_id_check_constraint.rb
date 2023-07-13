class MetaKeyIdCheckConstraint < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      ALTER TABLE meta_keys
      DROP CONSTRAINT meta_key_id_chars,
      DROP CONSTRAINT start_id_like_vocabulary_id;

      ALTER TABLE meta_keys
      ADD CONSTRAINT meta_key_id_chars
      CHECK ( id::text ~* ( '^' || vocabulary_id::text || ':[-_a-z0-9]+$' ) );
    SQL
  end
end
