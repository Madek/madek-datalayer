require 'spec_helper'

describe StaticPage do
  before { AppSetting.find_or_create_by(default_locale: 'de') }

  it 'should be producible by a factory' do
    expect { create(:static_page) }.not_to raise_error
  end

  describe 'name parameterization' do
    let(:name) { 'Terms of use!' }

    specify 'name is parameterized' do
      static_page = create(:static_page, name: name)

      expect(static_page.name).not_to eq(name)
      expect(static_page.name).to eq(name.parameterize)
    end
  end

  describe 'name existence' do
    context 'when name is nil' do
      it 'raises error' do
        expect { create(:static_page, name: nil) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end

    context 'when name is an empty string' do
      it 'raises error' do
        expect { create(:static_page, name: '') }.to raise_error(ActiveRecord::StatementInvalid)
        expect { create(:static_page, name: ' ') }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe 'name uniqueness' do
    it 'raises error' do
      static_page = create(:static_page)

      expect { create(:static_page, name: static_page.name) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'contents field' do
    it 'must have value for the default locale' do
      expect { create(:static_page, contents: nil) }.to raise_error(ActiveRecord::StatementInvalid)
      expect { create(:static_page, contents: {}) }.to raise_error(ActiveRecord::StatementInvalid)
      expect { create(:static_page, contents: { en: 'english content ' }) }
        .to raise_error(ActiveRecord::StatementInvalid)
      expect { create(:static_page, contents: { de: nil, en: 'english content' }) }
        .to raise_error(ActiveRecord::StatementInvalid)
      expect { create(:static_page, contents: { de: ' ' }) }
        .to raise_error(ActiveRecord::StatementInvalid)
      expect { create(:static_page, contents: { de: 'german content' }) }.not_to raise_error
    end
  end

end
