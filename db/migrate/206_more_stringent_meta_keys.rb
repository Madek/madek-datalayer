class MoreStringentMetaKeys < ActiveRecord::Migration[4.2]
  def change

    reversible do |dir|
      dir.up do


        ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
          SET session_replication_role = replica;
        SQL

        %w(is_extensible_list is_extensible keywords_alphabetical_order).each do |field|
          MetaKey.find_each do |mk|
            mk.update_attributes! field => !!mk[field]
          end
          change_column :meta_keys, field, :boolean, default: false, null: false
        end
        change_column :meta_keys, :keywords_alphabetical_order, :boolean, default: true, null: false

        %w(position).each do |field|
          MetaKey.find_each do |mk|
            mk.update_attributes! field => mk[field] || 0
          end
          change_column :meta_keys, field, :int, default: 0, null: false
        end

        %w(is_required).each do |field|
          ContextKey.find_each do |ck|
            ck.update_attributes! field => !!ck[field]
          end
          change_column :context_keys, field, :boolean, default: false, null: false
        end

        %w(position).each do |field|
          ContextKey.find_each do |ck|
            ck.update_attributes! field => ck[field] || 0
          end
          change_column :context_keys, field, :int, default: 0, null: false
        end

        execute <<-SQL.strip_heredoc
          CREATE TYPE text_element AS ENUM ('input', 'textarea')
        SQL
        add_column :context_keys, :text_element, :text_element, default: nil

        ContextKey.reset_column_information

        ContextKey.find_each do |ck|
          ck.update_attributes! text_element: \
            case ck['input_type']
            when 0
              'input'
            when 1
              'textarea'
            else
              nil
            end
        end

        remove_column :context_keys, :input_type

        ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
          SET session_replication_role = DEFAULT;
        SQL

      end
    end
  end
end
