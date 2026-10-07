require 'spec_helper'
require 'models/shared/orderable'

describe IoMapping do
  it_behaves_like 'orderable' do
    let(:parent_scope) { :io_interface }
  end
end
