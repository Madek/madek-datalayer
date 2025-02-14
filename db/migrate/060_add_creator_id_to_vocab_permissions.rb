class AddCreatorIdToVocabPermissions < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  def change
    [:vocabulary_api_client_permissions,
     :vocabulary_user_permissions,
     :vocabulary_group_permissions].each do |table|
       add_column table, :creator_id, :uuid
       add_foreign_key table, :users, column: :creator_id

       add_column table, :updator_id, :uuid
       add_foreign_key table, :users, column: :updator_id

       add_auto_timestamps table
     end

     # add `IF k = 'updator_id' THEN CONTINUE; END IF;`
     execute <<~SQL
       CREATE OR REPLACE FUNCTION public.jsonb_changed(jold jsonb, jnew jsonb) RETURNS jsonb
       LANGUAGE plpgsql
       AS $$
       DECLARE
         result JSONB := '{}'::JSONB;
         k TEXT;
         v_new JSONB;
         v_old JSONB;
       BEGIN
         FOR k IN SELECT * FROM jsonb_object_keys(jold || jnew) LOOP
           if jnew ? k
             THEN v_new := jnew -> k;
             ELSE v_new := 'null'::JSONB; END IF;
           if jold ? k
             THEN v_old := jold -> k;
             ELSE v_old := 'null'::JSONB; END IF;
           IF k = 'updated_at' THEN CONTINUE; END IF;
           IF k = 'updator_id' THEN CONTINUE; END IF;
           IF v_new = v_old THEN CONTINUE; END IF;
           result := result || jsonb_build_object(k, jsonb_build_array(v_old, v_new));
         END LOOP;
         RETURN result;
       END;
       $$;
     SQL
  end
end
