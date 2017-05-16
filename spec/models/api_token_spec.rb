require 'spec_helper'

describe ApiToken do
  context 'some user exists' do

    let :user do
      FactoryGirl.create :user
    end

    describe 'Creating an api_token' do
      it 'works' do
        expect(ApiToken.create user: user).to be_persisted
      end
    end

    describe 'A newly instantiated and saved api_token' do

      let :api_token do
        ApiToken.create user: user
      end

      it 'has a token' do
        expect(api_token.token).to be_present
      end

      it 'has a token_part which are the first 5 letters of the token' do
        expect(api_token.token_part).to be_present
        expect(api_token.token_part).to be == api_token.token.first(5)
      end

      it 'has a token_hash which which is the sha256 ' \
        'in Base64 encoded of the token' do
        expect(api_token.token_hash).to be == \
          Base64.strict_encode64(Digest::SHA256.digest(api_token.token))
      end

      it 'expires in about 1 year from now' do
        expires_at = api_token.reload.expires_at
        expect(Time.now + 1.year - 10.minutes).to be < expires_at
        expect(Time.now + 1.year + 10.minutes).to be > expires_at
      end

      describe 'the from the database instantiated token' do

        let :read_api_token do
          ApiToken.find api_token.id
        end

        it 'does have the same hash but the token itself is no more accessible' do
          expect(read_api_token.token_hash).to be == api_token.token_hash
          expect(read_api_token.token).not_to be_present
        end
      end

    end
  end
end
