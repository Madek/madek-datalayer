require 'spec_helper'
require 'spec_helper_no_tx'

describe MetaDatum::TextDate do

  describe 'Creation' do
    it 'should auto delete for empty string' do
      expect { FactoryBot.create :meta_datum_text_date, string: nil }
        .not_to change { MetaDatum.count }
    end

    it 'should sanitize special whitespace char and auto delete' do
      string = Madek::Constants::SPECIAL_WHITESPACE_CHARS.sample
      # using value= because of sanitization
      expect { FactoryBot.create :meta_datum_text_date, value: string }
        .not_to change { MetaDatum.count }
    end
  end
end
