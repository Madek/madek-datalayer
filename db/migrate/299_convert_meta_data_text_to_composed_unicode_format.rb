class ConvertMetaDataTextToComposedUnicodeFormat < ActiveRecord::Migration[4.2]
  def change

    MetaDatum::Text.find_each { |mdt| mdt.save! touch: false}

    execute <<-SQL.strip_heredoc
      ALTER TABLE keywords DISABLE TRIGGER USER;
    SQL
    Keyword.find_each {|kw| kw.save! touch: false}
    execute <<-SQL.strip_heredoc
      ALTER TABLE keywords ENABLE TRIGGER USER;
    SQL

  end
end
