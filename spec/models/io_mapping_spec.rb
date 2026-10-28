require 'spec_helper'
require 'models/shared/orderable'

describe IoMapping do
  it_behaves_like 'orderable' do
    let(:parent_scope) { :io_interface }
  end

  describe 'changing position' do
    let(:meta_key) { create(:meta_key_text) }
    let(:interface) { create(:io_interface) }
    let(:other_interface) { create(:io_interface) }
    let!(:m1) { create(:io_mapping, io_interface: interface, meta_key: meta_key) }
    let!(:o1) { create(:io_mapping, io_interface: other_interface, meta_key: meta_key) }
    let!(:m2) { create(:io_mapping, io_interface: interface, meta_key: meta_key) }
    let!(:o2) { create(:io_mapping, io_interface: other_interface, meta_key: meta_key) }
    let!(:m3) { create(:io_mapping, io_interface: interface, meta_key: meta_key) }

    def order_of(io_interface)
      IoMapping.where(io_interface: io_interface).reorder(:position).to_a
    end

    def positions_of(io_interface)
      IoMapping.where(io_interface: io_interface).reorder(:position).pluck(:position)
    end

    it 'numbers positions per interface on create' do
      expect(positions_of(interface)).to eq [0, 1, 2]
      expect(positions_of(other_interface)).to eq [0, 1]
    end

    describe '#move_up' do
      it 'swaps with the previous mapping of the same interface' do
        m2.move_up
        expect(order_of(interface)).to eq [m2, m1, m3]
      end

      it 'does nothing for the first mapping' do
        m1.move_up
        expect(order_of(interface)).to eq [m1, m2, m3]
      end
    end

    describe '#move_down' do
      it 'swaps with the next mapping of the same interface' do
        m2.move_down
        expect(order_of(interface)).to eq [m1, m3, m2]
      end

      it 'does nothing for the last mapping' do
        m3.move_down
        expect(order_of(interface)).to eq [m1, m2, m3]
      end
    end

    describe '#move_to_top' do
      it 'moves the mapping to the first position of its interface' do
        m3.move_to_top
        expect(order_of(interface)).to eq [m3, m1, m2]
      end

      it 'does nothing for the first mapping' do
        m1.move_to_top
        expect(order_of(interface)).to eq [m1, m2, m3]
      end
    end

    describe '#move_to_bottom' do
      it 'moves the mapping to the last position of its interface' do
        m1.move_to_bottom
        expect(order_of(interface)).to eq [m2, m3, m1]
      end

      it 'does nothing for the last mapping' do
        m3.move_to_bottom
        expect(order_of(interface)).to eq [m1, m2, m3]
      end
    end

    it 'never changes the order of another interface' do
      m2.move_up
      m3.move_to_top
      m1.move_to_bottom
      m2.move_down
      expect(order_of(other_interface)).to eq [o1, o2]
      expect(positions_of(other_interface)).to eq [0, 1]
    end

    it 'keeps positions gapless and unique within the interface' do
      m3.move_to_top
      m2.move_up
      m1.move_to_bottom
      expect(positions_of(interface)).to eq [0, 1, 2]
    end
  end
end
