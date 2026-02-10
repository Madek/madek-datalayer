class RemoveWorkflows < ActiveRecord::Migration[6.1]
  def up
    # Drop join tables
    drop_table :users_workflows
    drop_table :delegations_workflows
    
    # Remove workflow_id from collections
    remove_index :collections, name: :index_collections_on_workflow_id
    remove_column :collections, :workflow_id
    
    # Remove is_master from collections
    remove_column :collections, :is_master
    
    # Drop workflows table
    drop_table :workflows
    
    # Restore original check_no_drafts_in_collections function without workflow logic
    execute <<-SQL.strip_heredoc
      CREATE OR REPLACE FUNCTION check_no_drafts_in_collections()
      RETURNS trigger AS $$
      BEGIN
        IF (SELECT is_published FROM media_entries WHERE id = NEW.media_entry_id) = false
          THEN RAISE EXCEPTION 'Incomplete MediaEntries can not be put into Collections!';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    # Restore workflow-aware check_no_drafts_in_collections function
    execute <<-SQL.strip_heredoc
      CREATE OR REPLACE FUNCTION check_no_drafts_in_collections()
      RETURNS trigger AS $$
      BEGIN
        IF
          (SELECT is_published FROM media_entries WHERE id = NEW.media_entry_id) = false
          AND NOT EXISTS (
            SELECT 1 FROM workflows WHERE workflows.is_active = TRUE AND workflows.id IN (
              SELECT workflow_id FROM collections WHERE collections.id IN (
                WITH RECURSIVE parent_ids as (
                  SELECT parent_id
                  FROM collection_collection_arcs
                  WHERE child_id IN (
                    SELECT collection_id
                    FROM collection_media_entry_arcs
                    WHERE media_entry_id = NEW.media_entry_id
                  )
                  UNION
                    SELECT cca.parent_id
                    FROM collection_collection_arcs cca
                    JOIN parent_ids p ON cca.child_id = p.parent_id
                )
                SELECT parent_id FROM parent_ids
                UNION
                  SELECT cmea.collection_id
                  FROM collection_media_entry_arcs cmea
                  WHERE media_entry_id = NEW.media_entry_id
              )
            )
          )
          THEN RAISE EXCEPTION 'Incomplete MediaEntries can not be put into Collections!';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
    
    # Create workflows table
    create_table :workflows, id: :uuid do |t|
      t.string :name, null: false
      t.uuid :creator_id, null: false
      t.boolean :is_active, null: false, default: true
      t.jsonb :configuration, default: {}
      t.timestamp :created_at, default: -> { 'now()' }
      t.timestamp :updated_at, default: -> { 'now()' }
    end
    
    # Add workflow_id and is_master to collections
    add_column :collections, :workflow_id, :uuid
    add_column :collections, :is_master, :boolean, null: false, default: false
    add_index :collections, :workflow_id, name: :index_collections_on_workflow_id
    
    # Create join tables
    create_table :delegations_workflows, id: false do |t|
      t.uuid :delegation_id, null: false
      t.uuid :workflow_id, null: false
    end
    add_index :delegations_workflows, [:delegation_id, :workflow_id], 
              unique: true, name: :index_delegations_workflows_on_delegation_id_and_workflow_id
    add_index :delegations_workflows, [:workflow_id, :delegation_id],
              name: :index_delegations_workflows_on_workflow_id_and_delegation_id
    
    create_table :users_workflows, id: false do |t|
      t.uuid :user_id, null: false
      t.uuid :workflow_id, null: false
    end
    add_index :users_workflows, [:user_id, :workflow_id],
              name: :index_users_workflows_on_user_id_and_workflow_id
    add_index :users_workflows, [:workflow_id, :user_id],
              name: :index_users_workflows_on_workflow_id_and_user_id
    
    # Add foreign key constraint
    add_foreign_key :collections, :workflows, column: :workflow_id, name: :fk_rails_9085ae39f1
  end
end
