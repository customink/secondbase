module ThirdBase
  module Forced

    def connection_pool
      ThirdBase::Base.connection_pool
    end

    def retrieve_connection
      ThirdBase::Base.retrieve_connection
    end

    def connected?
      ThirdBase::Base.connected?
    end

    def remove_connection(klass = self)
      ThirdBase::Base.remove_connection
    end

  end
end
