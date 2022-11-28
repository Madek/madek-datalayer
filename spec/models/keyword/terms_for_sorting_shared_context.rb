require 'spec_helper'

# the order may be different on your local machine or even on prod (:-o), but
# this is how PG sorts on Cider's executors
shared_context :datalayer_terms_for_sorting do
  let(:terms) do
    ['0foo', '9foo', 'äfoo', 'Äfoo', 'bar', 'Bar', '#foo', 'foo', 'Foo', '合気道']
  end
end
