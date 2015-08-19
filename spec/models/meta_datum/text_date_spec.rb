require 'spec_helper'
require 'spec_helper_no_tx'

describe MetaDatum::TextDate do
  before :example do
    PgTasks.truncate_tables
  end

  describe 'Creation' do
    it 'should raise an error for empty string' do
      expect { FactoryGirl.create :meta_datum_text_date, string: nil }
        .to raise_error
    end
  end
end
