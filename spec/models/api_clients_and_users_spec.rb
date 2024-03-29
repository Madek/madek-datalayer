require 'spec_helper_no_tx'

describe [ApiClient, User] do
  context "existing user with login 'hans'" do
    describe 'creating a api_client with the same login' do
      it 'raises login must be unique' do
        expect do
          ActiveRecord::Base.transaction do
            FactoryBot.create :user, login: 'hans'
            FactoryBot.create :api_client, login: 'hans'
          end
        end.to raise_exception /login .* must be unique/
      end
    end
  end
  describe 'exiting a api_client with the same login' do
    context "creating user with login 'hans'" do
      it 'raises login must be unique' do
        expect do
          ActiveRecord::Base.transaction do
            FactoryBot.create :user, login: 'hans'
            FactoryBot.create :api_client, login: 'hans'
          end
        end.to raise_exception /login .* must be unique/
      end
    end
  end
end
