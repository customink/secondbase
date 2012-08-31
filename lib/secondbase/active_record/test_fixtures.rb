## ActiveRecord::TestFixtures
## Monkey patch active record's test_fixtures module to manage
## transactions for the SecondBase
module ActiveRecord
  module TestFixtures
    alias_method :original_setup_fixtures, :setup_fixtures
    alias_method :original_teardown_fixtures, :teardown_fixtures
    
    def setup_fixtures
      original_setup_fixtures
      # start tx for secondbase, if required
      # Load fixtures once and begin transaction.
      if run_in_transaction?
        SecondBase::Base.connection.increment_open_transactions
        SecondBase::Base.connection.transaction_joinable = false
        SecondBase::Base.connection.begin_db_transaction
      end
    end
    
    def teardown_fixtures
      original_teardown_fixtures
      
      # Rollback secondbase changes if a transaction is active.
      if run_in_transaction? && SecondBase::Base.connection.open_transactions != 0
        SecondBase::Base.connection.rollback_db_transaction
        SecondBase::Base.connection.decrement_open_transactions
      end
      
      SecondBase::Base.clear_active_connections!
    end
  end
end