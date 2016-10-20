class AddProgressToZencoderJobs < ActiveRecord::Migration
  def change
    add_column :zencoder_jobs, :progress, :float, default: 0.0

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE zencoder_jobs SET progress='100.0' WHERE state='finished'
        SQL
      end
    end
  end
end
