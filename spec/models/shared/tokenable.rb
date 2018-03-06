shared_examples 'tokenable' do
  include ActiveSupport::Testing::TimeHelpers

  context 'when user exists' do

    let(:user) { FactoryGirl.create(:user) }

    describe "Creating a #{described_class}" do
      it 'works' do
        expect(described_class.create user: user).to be_persisted
      end
    end

    describe "A newly instantiated and saved #{described_class}" do

      let :instance do
        described_class.create user: user
      end

      it 'has a token' do
        expect(instance.token).to be_present
      end

      it 'has a token_part which are the first 5 letters of the token' do
        expect(instance.token_part).to be_present
        expect(instance.token_part).to be == instance.token.first(5)
      end

      it 'has a token_hash which which is the sha256 ' \
        'in Base64 encoded of the token' do
        expect(instance.token_hash).to be == \
          Base64.strict_encode64(Digest::SHA256.digest(instance.token))
      end

      it 'expires in about 1 year from now' do
        expires_at = instance.reload.expires_at
        expect(Time.now + 1.year - 10.minutes).to be < expires_at
        expect(Time.now + 1.year + 10.minutes).to be > expires_at
      end

      describe "#{described_class} from the database" do

        let :read_instance do
          described_class.find instance.id
        end

        it 'does have the same hash but the token itself is no more accessible' do
          expect(read_instance.token_hash).to be == instance.token_hash
          expect(read_instance.token).not_to be_present
        end
      end

    end
  end

  describe '.find_by_token' do
    let(:user) { create :user }
    let!(:instance) { described_class.create(user: user) }
    let(:generated_token) { instance.token }

    it "finds not expired #{described_class}" do
      expect(described_class.find_by_token(generated_token)).to be
    end

    context 'when token is expired' do
      before { instance.reload }

      it "does not find #{described_class}" do
        travel(1.year + 1.second) do
          expect(instance.expires_at).not_to be_nil
          expect(described_class.find_by_token(generated_token)).not_to be
        end
      end
    end

    context 'when token is revoked' do
      let!(:instance) { described_class.create(user: user, revoked: true) }

      it "does not find #{described_class}" do
        expect(described_class.find_by_token(generated_token)).not_to be
      end
    end
  end
end
