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
    let!(:m1) { create(:io_mapping, io_interface: interface, meta_key: meta_key, key_map: 'm1') }
    let!(:o1) { create(:io_mapping, io_interface: other_interface, meta_key: meta_key, key_map: 'o1') }
    let!(:m2) { create(:io_mapping, io_interface: interface, meta_key: meta_key, key_map: 'm2') }
    let!(:o2) { create(:io_mapping, io_interface: other_interface, meta_key: meta_key, key_map: 'o2') }
    let!(:m3) { create(:io_mapping, io_interface: interface, meta_key: meta_key, key_map: 'm3') }

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

    it '#move_up swaps with the previous mapping of the same interface' do
      m2.move_up
      expect(order_of(interface)).to eq [m2, m1, m3]
    end

    it '#move_down swaps with the next mapping of the same interface' do
      m2.move_down
      expect(order_of(interface)).to eq [m1, m3, m2]
    end

    it '#move_to_top moves the mapping to the first position of its interface' do
      m3.move_to_top
      expect(order_of(interface)).to eq [m3, m1, m2]
    end

    it '#move_to_bottom moves the mapping to the last position of its interface' do
      m1.move_to_bottom
      expect(order_of(interface)).to eq [m2, m3, m1]
    end

    it 'does nothing when moving beyond the first or last mapping' do
      m1.move_up
      m1.move_to_top
      m3.move_down
      m3.move_to_bottom
      expect(order_of(interface)).to eq [m1, m2, m3]
    end

    it 'never changes the order of another interface' do
      m2.move_up
      m3.move_to_top
      m1.move_to_bottom
      m2.move_down
      expect(order_of(other_interface)).to eq [o1, o2]
      expect(positions_of(other_interface)).to eq [0, 1]
    end

    context 'within a filter' do
      let!(:c1) { create(:io_mapping, io_interface: interface, meta_key: meta_key, key_map: 'core_a') }
      let!(:other_core) do
        create(:io_mapping, io_interface: other_interface, meta_key: meta_key, key_map: 'core_x')
      end
      let!(:m4) { create(:io_mapping, io_interface: interface, meta_key: meta_key, key_map: 'm4') }
      let!(:c2) { create(:io_mapping, io_interface: interface, meta_key: meta_key, key_map: 'core_b') }
      let(:core) { IoMapping.filter_by('core') }

      it '#move_up swaps with the previous matching mapping, skipping hidden ones' do
        c2.move_up(core)
        expect(order_of(interface)).to eq [m1, m2, m3, c2, m4, c1]
      end

      it '#move_down swaps with the next matching mapping, skipping hidden ones' do
        c1.move_down(core)
        expect(order_of(interface)).to eq [m1, m2, m3, c2, m4, c1]
      end

      it 'does nothing at the edges of the filtered list' do
        c1.move_up(core)
        c2.move_down(core)
        expect(order_of(interface)).to eq [m1, m2, m3, c1, m4, c2]
      end

      it 'never swaps with a matching mapping of another interface' do
        c2.move_down(core)
        c1.move_up(core)
        expect(order_of(other_interface)).to eq [o1, o2, other_core]
      end

      it '#move_to_top moves to the top of the whole interface' do
        c2.move_to_top(core)
        expect(order_of(interface)).to eq [c2, m1, m2, m3, c1, m4]
      end

      it '#move_to_bottom moves to the bottom of the whole interface' do
        c1.move_to_bottom(core)
        expect(order_of(interface)).to eq [m1, m2, m3, m4, c2, c1]
      end

      it 'behaves like an unfiltered move without a relation' do
        c2.move_up
        expect(order_of(interface)).to eq [m1, m2, m3, c1, c2, m4]
      end
    end

    it 'appends the mapping to the end of its new interface' do
      m1.update!(io_interface: other_interface)
      expect(order_of(other_interface)).to eq [o1, o2, m1]
      expect(positions_of(other_interface)).to eq [0, 1, 2]
    end
  end
end
