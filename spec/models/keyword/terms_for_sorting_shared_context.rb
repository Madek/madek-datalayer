require 'spec_helper'

# Sort order with ICU de-CH collation (Cider CI + production DBs via create-db).
shared_context :datalayer_terms_for_sorting do
  let(:terms) do
    [
      '_foo', '-foo', '.foo', '#foo',
      '0foo', '2foo', '9foo',
      'aefoo', 'afoo', 'äfoo', 'Äfoo',
      'bar', 'Bar', 'efoo', 'éfoo',
      'foo', 'Foo', 'foo bar', 'foo-bar', 'foo.bar', 'foo2',
      'ofoo', 'öfoo', 'Öfoo',
      'ssfoo', 'ßfoo', 'zfoo', '合気道'
    ]
  end
end
