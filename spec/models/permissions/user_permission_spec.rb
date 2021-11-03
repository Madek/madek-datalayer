require 'spec_helper'

describe Permissions::UserPermission do
  describe '.permitted_for?' do
    let(:user) { double(:user) }

    context 'when passed resource is MediaEntry' do
      let(:resource) { MediaEntry.new }

      it 'passes arguments further to Permissions::MediaEntryUserPermission.permitted_for?' do
        expect(Permissions::MediaEntryUserPermission)
          .to receive(:permitted_for?)
          .with(:fake_permission, resource: resource, user: user)

        described_class.permitted_for?(:fake_permission,
                                       resource: resource,
                                       user: user)
      end
    end

    context 'when passed resource is Collection' do
      let(:resource) { Collection.new }

      it 'passes arguments further to Permissions::CollectionUserPermission.permitted_for?' do
        expect(Permissions::CollectionUserPermission)
          .to receive(:permitted_for?)
          .with(:fake_permission, resource: resource, user: user)

        described_class.permitted_for?(:fake_permission,
                                       resource: resource,
                                       user: user)
      end
    end

    context 'when passed resource is different class' do
      it 'raises error' do
        expect do
          described_class.permitted_for?(:fake_permission,
                                         resource: FilterSet.new,
                                         user: user)
        end.to raise_error 'Unsupported resource class: FilterSet'
      end
    end
  end
end
