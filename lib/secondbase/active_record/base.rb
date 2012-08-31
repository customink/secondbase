module ActiveRecord
  class Base
    
    # Arel is concerned with "engines".  Normally the engine defaults to the primary
    # connection (ActiveRecord::Base).  This will let us easily override the engine 
    # when dealing with Seoncdbase models (deep in ActiveRecord code).
    # Since SecondBase::Base inherits from ActiveRecord::Base, this will pass the
    # right engine around.
    def self.engine
      self
    end
  end
end