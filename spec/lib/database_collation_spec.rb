require 'spec_helper'

describe 'Database collation' do

  let(:collation) do
    ActiveRecord::Base.connection.select_one <<~SQL
      SELECT datlocprovider, daticulocale, datcollate, datctype
      FROM pg_database
      WHERE datname = current_database()
    SQL
  end

  let(:debug_info) do
    "database collation settings: #{collation.inspect}"
  end

  it 'uses ICU locale de-CH' do
    expect(collation['datlocprovider']).to eq('i'), debug_info
    expect(collation['daticulocale']).to eq('de-CH'), debug_info
  end
end
