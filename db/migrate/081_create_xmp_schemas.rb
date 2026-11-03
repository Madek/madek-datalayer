class CreateXmpSchemas < ActiveRecord::Migration[7.2]
  include Madek::MigrationHelper

  XMP_KEY = /\AXMP-([A-Za-z_][A-Za-z0-9_-]*):([A-Za-z_][A-Za-z0-9._-]*)\z/

  # Prefixes as used in ExifTool group names (`XMP-<prefix>`)
  KNOWN_NAMESPACES = {
    'dc' => ['http://purl.org/dc/elements/1.1/', false],
    'iptcCore' => ['http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/', false],
    'photoshop' => ['http://ns.adobe.com/photoshop/1.0/', false],
    'xmpRights' => ['http://ns.adobe.com/xap/1.0/rights/', false],
    'madek' => ['http://madek.zhdk.ch/madek/1.0/', true],
    'madekzhdk' => ['http://medienarchiv.zhdk.ch/ns/madekzhdk/', true]
  }.freeze

  DC_VALUE_TYPES = {
    'creator' => 'seq Text',
    'description' => 'Lang Alt',
    'rights' => 'Lang Alt',
    'subject' => 'bag Text',
    'title' => 'Lang Alt',
    'type' => 'bag Text'
  }.freeze

  def up
    create_table :xmp_namespaces, id: :uuid do |t|
      t.string :prefix, null: false
      t.string :uri, null: false
      t.boolean :is_managed, null: false, default: true
      t.hstore :labels, null: false, default: {}
      t.hstore :descriptions, null: false, default: {}
    end
    add_auto_timestamps :xmp_namespaces, null: false
    add_index :xmp_namespaces, :prefix, unique: true
    add_index :xmp_namespaces, :uri, unique: true

    execute <<-SQL.strip_heredoc
      ALTER TABLE xmp_namespaces
        ADD CONSTRAINT xmp_namespaces_prefix_format
          CHECK (prefix ~ '^[A-Za-z_][A-Za-z0-9_-]*$'),
        ADD CONSTRAINT xmp_namespaces_uri_format
          CHECK (uri ~ '[/#]$');
    SQL

    create_table :xmp_properties, id: :uuid do |t|
      t.uuid :xmp_namespace_id, null: false
      t.string :name, null: false
      t.string :value_type, null: false, default: 'Text'
      t.integer :position, null: false, default: 0
      t.hstore :labels, null: false, default: {}
      t.hstore :descriptions, null: false, default: {}
    end
    add_auto_timestamps :xmp_properties, null: false
    add_foreign_key :xmp_properties, :xmp_namespaces, on_delete: :cascade
    # ExifTool does not distinguish names differing in case only
    add_index :xmp_properties, 'xmp_namespace_id, lower(name)',
              unique: true, name: 'idx_xmp_properties_namespace_name'

    execute <<-SQL.strip_heredoc
      ALTER TABLE xmp_properties
        ADD CONSTRAINT xmp_properties_name_format
          CHECK (name ~ '^[A-Za-z_][A-Za-z0-9._-]*$'),
        ADD CONSTRAINT xmp_properties_value_type
          CHECK (value_type IN ('Text', 'Integer', 'Boolean', 'Date', 'URI',
                                'Lang Alt', 'bag Text', 'seq Text'));
    SQL

    add_column :io_mappings, :xmp_property_id, :uuid
    add_column :io_mappings, :position, :integer, null: false, default: 0
    add_foreign_key :io_mappings, :xmp_properties, on_delete: :restrict
    add_index :io_mappings, :xmp_property_id

    execute <<-SQL.strip_heredoc
      ALTER TABLE io_mappings
        ADD CONSTRAINT io_mappings_key_map_or_xmp_property
          CHECK (key_map IS NULL OR xmp_property_id IS NULL);
    SQL

    %w(xmp_namespaces xmp_properties).each do |table|
      execute <<-SQL.strip_heredoc
        CREATE TRIGGER #{table}_audit_change
        AFTER INSERT OR DELETE OR UPDATE ON #{table}
        FOR EACH ROW EXECUTE FUNCTION audit_change();
      SQL
    end

    migrate_xmp_key_maps
  end

  def down
    execute <<-SQL.strip_heredoc
      UPDATE io_mappings
      SET key_map = 'XMP-' || xmp_namespaces.prefix || ':' ||
                    upper(left(xmp_properties.name, 1)) ||
                    substring(xmp_properties.name FROM 2)
      FROM xmp_properties
      JOIN xmp_namespaces ON xmp_namespaces.id = xmp_properties.xmp_namespace_id
      WHERE io_mappings.xmp_property_id = xmp_properties.id
    SQL
    remove_column :io_mappings, :xmp_property_id
    remove_column :io_mappings, :position
    drop_table :xmp_properties
    drop_table :xmp_namespaces
  end

  private

  # Converts key maps consisting of XMP keys only into property references;
  # each further comma-separated key becomes an additional row.
  def migrate_xmp_key_maps
    select_all('SELECT * FROM io_mappings WHERE key_map IS NOT NULL').each do |row|
      keys = row['key_map'].split(',').map(&:strip).reject(&:empty?)
      matches = keys.map { |key| XMP_KEY.match(key) }
      next if matches.empty? || matches.any?(&:nil?)

      matches.each_with_index do |match, index|
        property_id = find_or_create_property(match[1], match[2])
        if index.zero?
          execute <<-SQL.strip_heredoc
            UPDATE io_mappings
            SET key_map = NULL, xmp_property_id = #{quote(property_id)}, position = 0
            WHERE id = #{quote(row['id'])}
          SQL
        else
          execute <<-SQL.strip_heredoc
            INSERT INTO io_mappings
              (io_interface_id, meta_key_id, key_map_type, xmp_property_id, position)
            VALUES (#{quote(row['io_interface_id'])}, #{quote(row['meta_key_id'])},
                    #{quote(row['key_map_type'])}, #{quote(property_id)}, #{index})
          SQL
        end
      end
    end
  end

  def find_or_create_property(prefix, exiftool_name)
    namespace_id = find_or_create_namespace(prefix)
    # Dublin Core element names are lower case, ExifTool capitalizes them
    name = prefix == 'dc' ? exiftool_name.sub(/\A./, &:downcase) : exiftool_name

    existing_id = select_value(<<-SQL.strip_heredoc)
      SELECT id FROM xmp_properties
      WHERE xmp_namespace_id = #{quote(namespace_id)} AND lower(name) = lower(#{quote(name)})
    SQL
    existing_id || insert_property(namespace_id, prefix, name)
  end

  def insert_property(namespace_id, prefix, name)
    value_type = (prefix == 'dc' && DC_VALUE_TYPES[name]) || 'Text'
    select_value(<<-SQL.strip_heredoc)
      INSERT INTO xmp_properties (xmp_namespace_id, name, value_type)
      VALUES (#{quote(namespace_id)}, #{quote(name)}, #{quote(value_type)})
      RETURNING id
    SQL
  end

  # Unknown prefixes get a placeholder URI to be replaced by an admin
  def find_or_create_namespace(prefix)
    uri, is_managed = KNOWN_NAMESPACES.fetch(prefix, ["urn:madek:xmp-namespace:#{prefix}/", true])

    existing_id = select_value(
      "SELECT id FROM xmp_namespaces WHERE prefix = #{quote(prefix)}")
    existing_id || select_value(<<-SQL.strip_heredoc)
      INSERT INTO xmp_namespaces (prefix, uri, is_managed)
      VALUES (#{quote(prefix)}, #{quote(uri)}, #{is_managed})
      RETURNING id
    SQL
  end
end
