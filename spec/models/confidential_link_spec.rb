require 'spec_helper'

describe ConfidentialLink do
  include ActiveSupport::Testing::TimeHelpers

  context 'when user exists' do

    let(:user) { FactoryGirl.create(:user) }

    describe 'Creating' do
      it 'works' do
        expect(described_class.create user: user).to be_persisted
      end
    end

    describe 'A newly instantiated and saved' do

      let :instance do
        described_class.create user: user
      end

      it 'has a token' do
        expect(instance.token).to be_present
      end

      it 'never expires' do
        expect(instance.reload.expires_at).to be nil
      end
    end
  end

  describe '.find_by_token!' do
    let(:user) { create :user }
    let!(:instance) { described_class.create(user: user) }
    let(:generated_token) { instance.token }

    context 'when token is not expired' do
      it 'finds' do
        expect(described_class.find_by_token!(generated_token)).to be
      end
    end

    context 'when token is expired' do
      before do
        instance.update_attribute(:expires_at, 1.day.ago)
      end

      it 'raises an error' do
        expect(instance.expires_at).not_to be_nil
        expect { described_class.find_by_token!(generated_token) }.to \
          raise_error(
            ActiveRecord::RecordNotFound, "Couldn't find ConfidentialLink")
      end
    end

    context 'when token is revoked' do
      let!(:instance) { described_class.create(user: user, revoked: true) }

      it 'raises an error' do
        expect { described_class.find_by_token!(generated_token) }.to \
          raise_error(
            ActiveRecord::RecordNotFound, "Couldn't find ConfidentialLink")
      end
    end
  end
end
