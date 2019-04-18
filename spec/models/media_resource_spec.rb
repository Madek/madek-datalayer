require 'spec_helper'

describe MediaResource do
  describe '#cast_to_type' do
    context 'when its type of MediaEntry' do
      it 'returns MediaEntry instance' do
        allow(subject).to receive(:type).and_return('MediaEntry')

        expect(subject.cast_to_type)
          .to be_instance_of(MediaEntry)
      end
    end

    context 'when its type of Collection' do
      it 'returns Collection instance' do
        allow(subject).to receive(:type).and_return('Collection')

        expect(subject.cast_to_type)
          .to be_instance_of(Collection)
      end
    end

    context 'when its type of FilterSet' do
      it 'returns FilterSet instance' do
        allow(subject).to receive(:type).and_return('FilterSet')

        expect(subject.cast_to_type)
          .to be_instance_of(FilterSet)
      end
    end
  end
end
