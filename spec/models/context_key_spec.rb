require 'spec_helper'
require 'models/shared/saving_empty_strings'
require 'models/shared/orderable'
require 'models/shared/assigning_localized_fields'

describe ContextKey do
  it_ensures 'saving empty strings' do
    let(:model) { create :context_key }
  end

  it_behaves_like 'orderable' do
    let(:parent_scope) { :context }
  end

  it_ensures 'assigning localized fields'
end
