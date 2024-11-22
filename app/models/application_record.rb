class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.valid_uuid?(uuid)
    UUIDTools::UUID_REGEXP =~ uuid
  end

  # Executes a block of code within a database transaction.
  # Ensures that all constraints are checked immediately after the block is executed.
  # This is done because the outermost transaction is found in the audit middleware
  # and PG implements single commit/rollback for nested transactions. So if one
  # uses DEFERRABLE constraints, they are normally checked at the end of the outermost
  # transaction.
  def self.tx_with_set_constraints_all_immediate
    ActiveRecord::Base.transaction do 
      yield
      ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL IMMEDIATE")
    end
  end
end
