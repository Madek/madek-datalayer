FactoryBot.define do

  factory :collection_api_client_permission,
          class: Permissions::CollectionApiClientPermission do

    get_metadata_and_previews { FactoryHelper.rand_bool 1 / 2.0 }
    edit_metadata_and_relations { FactoryHelper.rand_bool 1 / 4.0 }

    api_client { ApiClient.find_random || (FactoryBot.create :api_client) }
    updator { User.find_random || (FactoryBot.create :user) }
    collection { Collection.find_random || (FactoryBot.create :collection) }

  end

  factory :collection_group_permission,
          class: Permissions::CollectionGroupPermission do

    get_metadata_and_previews { FactoryHelper.rand_bool 1 / 2.0 }
    edit_metadata_and_relations { FactoryHelper.rand_bool 1 / 4.0 }

    group { Group.find_random || (FactoryBot.create :group) }
    updator { User.find_random || (FactoryBot.create :user) }
    collection { Collection.find_random || (FactoryBot.create :collection) }

  end

  factory :media_entry_user_permission,
          class: Permissions::MediaEntryUserPermission do

    get_metadata_and_previews { FactoryHelper.rand_bool 1 / 4.0 }
    get_full_size { get_metadata_and_previews and FactoryHelper.rand_bool }
    edit_metadata { FactoryHelper.rand_bool 1 / 4.0 }
    edit_permissions { edit_metadata and FactoryHelper.rand_bool }

    user { User.find_random || (FactoryBot.create :user) }
    updator { User.find_random || (FactoryBot.create :user) }
    media_entry { MediaEntry.find_random || (FactoryBot.create :media_entry) }

  end

  factory :media_entry_delegation_permission,
          class: Permissions::MediaEntryUserPermission do

      get_metadata_and_previews { FactoryHelper.rand_bool 1 / 4.0 }
      get_full_size { get_metadata_and_previews and FactoryHelper.rand_bool }
      edit_metadata { FactoryHelper.rand_bool 1 / 4.0 }
      edit_permissions { edit_metadata and FactoryHelper.rand_bool }

      delegation { Delegation.find_random || (FactoryBot.create :delegation) }
      updator { User.find_random || (FactoryBot.create :user) }
      media_entry { MediaEntry.find_random || (FactoryBot.create :media_entry) }

  end

  factory :collection_user_permission,
          class: Permissions::CollectionUserPermission do

    get_metadata_and_previews { FactoryHelper.rand_bool 1 / 4.0 }
    edit_metadata_and_relations { FactoryHelper.rand_bool 1 / 4.0 }
    edit_permissions { FactoryHelper.rand_bool 1 / 4.0 }

    user { User.find_random || (FactoryBot.create :user) }
    updator { User.find_random || (FactoryBot.create :user) }
    collection { Collection.find_random || (FactoryBot.create :collection) }

  end

  factory :collection_delegation_permission,
          class: Permissions::CollectionUserPermission do

      get_metadata_and_previews { FactoryHelper.rand_bool 1 / 4.0 }
      edit_metadata_and_relations { FactoryHelper.rand_bool 1 / 4.0 }
      edit_permissions { FactoryHelper.rand_bool 1 / 4.0 }

      delegation { Delegation.find_random || (FactoryBot.create :delegation) }
      updator { User.find_random || (FactoryBot.create :user) }
      collection { Collection.find_random || (FactoryBot.create :collection) }

  end

  factory :media_entry_group_permission,
          class: Permissions::MediaEntryGroupPermission do

    get_metadata_and_previews { FactoryHelper.rand_bool 1 / 4.0 }
    get_full_size { get_metadata_and_previews and FactoryHelper.rand_bool }
    edit_metadata { FactoryHelper.rand_bool 1 / 4.0 }

    group { Group.find_random || (FactoryBot.create :group) }
    updator { User.find_random || (FactoryBot.create :user) }
    media_entry { MediaEntry.find_random || (FactoryBot.create :media_entry) }

  end

  factory :media_entry_api_client_permission,
          class: Permissions::MediaEntryApiClientPermission do

    get_metadata_and_previews { FactoryHelper.rand_bool 1 / 4.0 }
    get_full_size { get_metadata_and_previews and FactoryHelper.rand_bool }

    api_client { ApiClient.find_random || (FactoryBot.create :api_client) }
    updator { User.find_random || (FactoryBot.create :user) }
    media_entry { MediaEntry.find_random || (FactoryBot.create :media_entry) }

  end

  factory :vocabulary_api_client_permission,
          class: Permissions::VocabularyApiClientPermission do
    use { FactoryHelper.rand_bool 1 / 4.0 }
    view { FactoryHelper.rand_bool 1 / 2.0 }
    vocabulary { Vocabulary.find_random || (FactoryBot.create :vocabulary) }
    api_client { FactoryBot.create :api_client }
  end

  factory :vocabulary_group_permission,
          class: Permissions::VocabularyGroupPermission do
    use { FactoryHelper.rand_bool 1 / 4.0 }
    view { FactoryHelper.rand_bool 1 / 2.0 }
    vocabulary { Vocabulary.find_random || (FactoryBot.create :vocabulary) }
    group { FactoryBot.create :group }
  end

  factory :vocabulary_user_permission,
          class: Permissions::VocabularyUserPermission do
    use { FactoryHelper.rand_bool 1 / 4.0 }
    view { FactoryHelper.rand_bool 1 / 2.0 }
    vocabulary { Vocabulary.find_random || (FactoryBot.create :vocabulary) }
    user { FactoryBot.create :user }
  end

end
