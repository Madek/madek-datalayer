RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_implements, 'it implements'
end

shared_examples '.permitted_for?' do |permission_types = described_class::PERMISSION_TYPES|
  let(:user) { create(:user) }
  let(:delegation) { create(:delegation) }
  let(:resource_key) { resource.model_name.to_s.underscore }

  shared_examples 'expects false for all permissions' do
    permission_types.each do |perm_type|
      it "returns false for #{perm_type} permission" do
        expect(
          described_class.permitted_for?(
            perm_type,
            user: user,
            resource: resource
          )
        ).to eq(false)
      end
    end
  end

  context 'when user is not reachable at all' do
    before do
      described_class.create!(
        user: create(:user),
        resource_key => resource
      )
    end

    include_examples 'expects false for all permissions'
  end

  context 'when user is reachable directly' do
    context 'when all permissions are set to false' do
      before do
        described_class.create!(
          user: user,
          resource_key => resource
        )
      end

      include_examples 'expects false for all permissions'
    end

    context 'when a permission is set to true' do
      let(:random_permission) { permission_types.sample }

      before do
        described_class.create!(
          user: user,
          resource_key => resource,
          random_permission => true
        )
      end

      it 'returns true for the truthy permission' do
        expect(
          described_class.permitted_for?(
            random_permission,
            user: user,
            resource: resource
          )
        ).to eq(true)
      end
    end
  end

  context 'when user is reachable directly through a delegation' do
    before do
      delegation.users << user
    end

    context 'when all permissions are set to false' do
      before do
        described_class.create!(
          delegation: delegation,
          resource_key => resource
        )
      end

      include_examples 'expects false for all permissions'
    end

    context 'when a permission is set to true' do
      let(:random_permission) { permission_types.sample }

      before do
        described_class.create!(
          delegation: delegation,
          resource_key => resource,
          random_permission => true
        )
      end

      it 'returns true for the truthy permission' do
        expect(
          described_class.permitted_for?(
            random_permission,
            user: user,
            resource: resource
          )
        ).to eq(true)
      end
    end
  end

  context 'when user is reachable through a delegation\'s group' do
    before do
      group = create(:group)
      group.users << user
      delegation.groups << group
    end

    context 'when all permissions are set to false' do
      before do
        described_class.create!(
          delegation: delegation,
          resource_key => resource
        )
      end

      include_examples 'expects false for all permissions'
    end

    context 'when a permission is set to true' do
      let(:random_permission) { permission_types.sample }

      before do
        described_class.create!(
          delegation: delegation,
          resource_key => resource,
          random_permission => true
        )
      end

      it 'returns true for the truthy permission' do
        expect(
          described_class.permitted_for?(
            random_permission,
            user: user,
            resource: resource
          )
        ).to eq(true)
      end
    end
  end
end
