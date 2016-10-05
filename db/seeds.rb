ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
    SET session_replication_role = replica;
  SQL

  Vocabulary.find_or_create_by(id: 'madek_core').update_attributes!  \
    label: 'Madek Core',
    description: 'This is the predefined and immutable Madek core vocabulary.'

  Context.find_or_create_by(id: 'core').update_attributes! \
    label: "Core",
    description: "Die Metadaten dieses Kontextes sind in der ME-Detailansicht links neben dem Thumbnail sichtbar. Der Core-Kontext wird auch in der Listenansicht usw. verwendet."

  YAML.load_file(Rails.root.join("db","madek_core_meta_keys.yml")).each do |id,attrs|
    MetaKey.find_or_initialize_by(id: id).update_attributes! attrs
    ContextKey.find_or_create_by(context_id: 'core', meta_key_id: id)
  end

  if AppSetting.first.catalog_context_keys.empty?
    ck = ContextKey.find_by(context_id: 'core', meta_key_id: 'madek_core:keywords')
    AppSetting.first.update_attributes!(catalog_context_keys: [ck.id])
  end

  %w(madek_core:title madek_core:copyright_notice).each do |mkid|
    ContextKey.find_by(meta_key_id: mkid, context_id: 'core') \
      .update_attributes! is_required: true
  end

  ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
    SET session_replication_role = DEFAULT;
  SQL


  %w(label description hint).each do |column_name|
    ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
      UPDATE context_keys
        SET #{column_name} = NULL
        FROM meta_keys
        WHERE meta_key_id = meta_keys.id
        AND meta_keys.#{column_name} = context_keys.#{column_name}
    SQL
  end

end
