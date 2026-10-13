# The meta_data_people indexes are partial (WHERE role_id IS [NOT] NULL), so
# lookups by meta_datum_id (the authors of a resource, the list preload) or by
# person_id (person pages, the person filter) scan the table. custom_urls has
# no index on its foreign keys, and every list item looks up its custom URLs.
#
# On large instances, create the indexes beforehand without blocking writes,
# under the same names; the migration then skips them:
#
#   CREATE INDEX CONCURRENTLY index_meta_data_people_on_meta_datum_id
#     ON public.meta_data_people USING btree (meta_datum_id);
#   CREATE INDEX CONCURRENTLY index_meta_data_people_on_person_id
#     ON public.meta_data_people USING btree (person_id);
#   CREATE INDEX CONCURRENTLY index_custom_urls_on_media_entry_id
#     ON public.custom_urls USING btree (media_entry_id);
#   CREATE INDEX CONCURRENTLY index_custom_urls_on_collection_id
#     ON public.custom_urls USING btree (collection_id);
class AddJoinTableLookupIndexes < ActiveRecord::Migration[7.2]
  INDEXES = [
    [:meta_data_people, :meta_datum_id],
    [:meta_data_people, :person_id],
    [:custom_urls, :media_entry_id],
    [:custom_urls, :collection_id]
  ].freeze

  def up
    INDEXES.each do |table, column|
      add_index table, column, if_not_exists: true
    end
  end

  def down
    INDEXES.reverse_each do |table, column|
      remove_index table, column, if_exists: true
    end
  end
end
