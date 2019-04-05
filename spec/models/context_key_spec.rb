require 'spec_helper'
require 'models/shared/orderable'
require 'models/shared/assigning_localized_fields'
require 'models/shared/blank_localized_fields'

describe ContextKey do
  it_behaves_like 'orderable' do
    let(:parent_scope) { :context }
  end

  it_ensures 'assigning localized fields'
  it_handles 'blank localized fields' do
    let(:factory_name) { :context_key }
  end
end
