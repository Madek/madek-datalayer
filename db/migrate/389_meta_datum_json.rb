class MetaDatumJson < ActiveRecord::Migration[5.2]
  include Madek::MigrationHelper


  def before_types
    [ 'MetaDatum::Groups',
      'MetaDatum::Keywords',
      'MetaDatum::Licenses',
      'MetaDatum::People',
      'MetaDatum::Roles',
      'MetaDatum::Text',
      'MetaDatum::Text',
      'MetaDatum::TextDate',
      'MetaDatum::Users',
      'MetaDatum::Vocables',]
  end

  def after_types
    before_types << 'MetaDatum::JSON'
  end


  def drop_constraints
    execute %[ALTER TABLE meta_data DROP CONSTRAINT check_valid_type]
    execute %[ALTER TABLE meta_keys DROP CONSTRAINT check_valid_meta_datum_object_type]
  end


  def change
    add_column :meta_data, :json, :jsonb, default: nil

    reversible do |dir|
      dir.up do
        drop_constraints
        execute %[ALTER TABLE meta_data ADD CONSTRAINT check_valid_type CHECK (type IN (#{after_types.uniq.map{|s|"'#{s}'"}.join(', ')}));]
        execute %[ALTER TABLE meta_keys ADD CONSTRAINT check_valid_meta_datum_object_type CHECK (meta_datum_object_type IN (#{after_types.uniq.map{|s|"'#{s}'"}.join(', ')}));]
      end

      dir.down do
        drop_constraints
        execute %[ALTER TABLE meta_data ADD CONSTRAINT check_valid_type CHECK (type IN (#{before_types.uniq.map{|s|"'#{s}'"}.join(', ')}));]
        execute %[ALTER TABLE meta_keys ADD CONSTRAINT check_valid_meta_datum_object_type CHECK (meta_datum_object_type IN (#{before_types.uniq.map{|s|"'#{s}'"}.join(', ')}));]
      end
    end
  end

end
