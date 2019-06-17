require 'spec_helper'
require 'spec_helper_personas'

# TODO: remove this after refactoring?

# This relies on the personas_db and runs static assertions
# after it is migrated from v2 to v3.
describe 'Migration from v2 to v3' do

  it 'User.used_keywords' do
    normin = User.find_by(login: 'normin')

    # from v2: `normin.keywords.map(&:keyword_term).map(&:term)` =>
    normins_useds_terms = ['oil', 'niger delta', 'Installation']

    expect(normin.used_keywords.map(&:term))
      .to match_array(normins_useds_terms)
  end

  it 'has correct AppSetting: Context-/MetaData-Display' do
    settings = AppSetting.first
    # hardcoded in v2, should be set in v3 to not break
    # existing instances
    expect(settings.context_for_entry_summary.id).to eq 'core'
    expect(settings.context_for_collection_summary.id).to eq 'core'
    expect(settings.contexts_for_entry_validation.map(&:id)).to eq ['upload']
  end

end
