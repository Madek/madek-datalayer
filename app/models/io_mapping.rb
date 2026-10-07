class IoMapping < ApplicationRecord
  include IoMappings::Filters
  include Orderable

  enable_ordering parent_scope: :io_interface

  # Swap with the nearest mapping of the same interface within `scope`
  # (e.g. a search filter), skipping mappings hidden by it.
  %i(up down).each do |direction|
    define_method "move_#{direction}" do |scope = IoMapping.all|
      operator, order = direction == :up ? ['<', :desc] : ['>', :asc]
      transaction do
        regenerate_positions
        neighbour =
          scope
            .where(io_interface_id: io_interface_id)
            .where("io_mappings.position #{operator} ?", position)
            .reorder(position: order)
            .first
        next unless neighbour

        own_position = position
        update_attribute(:position, neighbour.position)
        neighbour.update_attribute(:position, own_position)
      end
    end
  end

  belongs_to :io_interface
  belongs_to :meta_key

  before_update if: :io_interface_id_changed? do
    self.position =
      (IoMapping.where(io_interface_id: io_interface_id).maximum(:position) || -1) + 1
  end
end
