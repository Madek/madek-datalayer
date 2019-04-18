class AddRolesMetaDatumObjectType < ActiveRecord::Migration[4.2]
  def before_types
    [ 'MetaDatum::Licenses',
      'MetaDatum::Text',
      'MetaDatum::TextDate',
      'MetaDatum::Groups',
      'MetaDatum::Keywords',
      'MetaDatum::Vocables',
      'MetaDatum::People',
      'MetaDatum::Text',
      'MetaDatum::Users' ]
  end

  def after_types
    before_types << 'MetaDatum::Roles'
  end

  def drop_constraints
    execute %[ALTER TABLE meta_data DROP CONSTRAINT check_valid_type]
    execute %[ALTER TABLE meta_keys DROP CONSTRAINT check_valid_meta_datum_object_type]
  end

  def change
    reversible do |dir|
      dir.up do
        drop_constraints
        execute %[ALTER TABLE meta_data ADD CONSTRAINT check_valid_type CHECK (type IN (#{after_types.uniq.map{|s|"'#{s}'"}.join(', ')}));]
        execute %[ALTER TABLE meta_keys ADD CONSTRAINT check_valid_meta_datum_object_type CHECK (meta_datum_object_type IN (#{after_types.uniq.map{|s|"'#{s}'"}.join(', ')}));]
      end

      dir.down do
        drop_constraints
        MetaKey.where(meta_datum_object_type: 'MetaDatum::Roles').destroy_all
        execute %[ALTER TABLE meta_data ADD CONSTRAINT check_valid_type CHECK (type IN (#{before_types.uniq.map{|s|"'#{s}'"}.join(', ')}));]
        execute %[ALTER TABLE meta_keys ADD CONSTRAINT check_valid_meta_datum_object_type CHECK (meta_datum_object_type IN (#{before_types.uniq.map{|s|"'#{s}'"}.join(', ')}));]
      end
    end

  end
end
