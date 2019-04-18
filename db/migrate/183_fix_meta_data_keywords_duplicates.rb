class FixMetaDataKeywordsDuplicates < ActiveRecord::Migration[4.2]
  class MetaDataKeywords < ActiveRecord::Base
    self.table_name = 'meta_data_keywords'
    belongs_to :meta_datum
    belongs_to :keyword
    belongs_to :created_by, class_name: 'User'
  end

  def up
    # ################################
    # fix duplicate meta_data_keywords
    # ################################
    MetaDataKeywords.all.each do |mdk|
      MetaDataKeywords
        .where(meta_datum_id: mdk.meta_datum_id, keyword_id: mdk.keyword_id)
        .drop(1)
        .each(&:delete)
    end
  end
end
