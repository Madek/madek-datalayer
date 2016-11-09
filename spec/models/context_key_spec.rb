require 'spec_helper'
require Rails.root.join 'spec', 'models', 'shared', 'saving_empty_strings.rb'

describe ContextKey do
  it_ensures 'saving empty strings' do
    let(:model) { create :context_key }
  end
end
