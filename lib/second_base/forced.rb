module SecondBase
  module Forced

    def connection_pool
      SecondBase::Base.connection_pool
    end

    def retrieve_connection
      SecondBase::Base.retrieve_connection
    end

    def connected?
      SecondBase::Base.connected?
    end

    def remove_connection(klass = self)
      SecondBase::Base.remove_connection
    end

  end
end
