module ThirdBase
  class Base < ActiveRecord::Base

    self.abstract_class = true
    establish_connection ThirdBase.config

  end
end
