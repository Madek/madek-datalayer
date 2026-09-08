module TransactionHealing
  extend ActiveSupport::Concern

  # Madek::Middleware::Audit wraps every unsafe-method request in one outer
  # transaction. A DB-level error during the action aborts that transaction at
  # the connection level, which would otherwise stay aborted (breaking further
  # queries, e.g. the error page's own nav bar, or a subsequent redirect's own
  # callbacks) until the middleware's COMMIT. Running the action in a
  # savepoint lets `render`/`redirect_to` below roll back to just that
  # savepoint instead, healing the connection while leaving the outer
  # transaction (and deferred-constraint timing) untouched. See #946.
  included do
    around_action :run_in_savepoint_transaction
  end

  # Heals the connection right before any response is produced, so a
  # controller that rescues a DB error itself and then renders/redirects
  # doesn't hit the still-aborted connection.
  def render(...)
    heal_transaction_if_aborted
    super
  end

  def redirect_to(...)
    heal_transaction_if_aborted
    super
  end

  private

  def run_in_savepoint_transaction
    return yield unless ActiveRecord::Base.connection.transaction_open?

    ActiveRecord::Base.transaction(requires_new: true) do
      yield
      raise ActiveRecord::Rollback if transaction_aborted?
    end
  end

  def heal_transaction_if_aborted
    return unless transaction_aborted?

    connection = ActiveRecord::Base.connection
    savepoint = connection.current_savepoint_name
    connection.rollback_to_savepoint(savepoint) if savepoint
  end

  def transaction_aborted?
    connection = ActiveRecord::Base.connection
    connection.transaction_open? &&
      connection.raw_connection.transaction_status == PG::PQTRANS_INERROR
  end
end
