require 'spec_helper'
require 'models/shared/orderable'
require 'models/shared/assigning_localized_fields'

describe Vocabulary do
  it_behaves_like 'orderable'
  it_ensures 'assigning localized fields', without_hints: true
end
