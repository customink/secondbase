module SecondBase
  class Base < ActiveRecord::Base

    self.abstract_class = true
    establish_connection SecondBase.config

  end
end
