FactoryBot.define do
  factory :collection_media_entry_arc, class: Arcs::CollectionMediaEntryArc do
    order { rand < 0.75 ? rand : nil }
    collection
    media_entry
  end

  factory :collection_collection_arc, class: Arcs::CollectionCollectionArc do
    association :parent, factory: :collection
    association :child, factory: :collection
  end

end
