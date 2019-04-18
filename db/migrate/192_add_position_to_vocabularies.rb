class AddPositionToVocabularies < ActiveRecord::Migration[4.2]
  def change
    add_column :vocabularies, :position, :integer
    add_index :vocabularies, :position

    Vocabulary.reset_column_information
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          Vocabulary.all.each_with_index do |vocabulary, i|
            vocabulary.update!(position: i)
          end
        end
      end
    end
  end
end
