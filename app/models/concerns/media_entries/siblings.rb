module MediaEntries
  module Siblings
    def sibling_media_entries(user)
      [].tap do |result|
        parent_collections
          .viewable_by_user_or_public(user)
          .includes(:media_entries)
          .each do |parent_collection|
            result << {
              collection: parent_collection,
              media_entries: parent_collection
                .media_entries
                .where.not(id: id)
                .viewable_by_user_or_public(user)
                .limit(100)
            }
          end
      end
    end
  end
end
