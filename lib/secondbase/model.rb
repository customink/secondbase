module SecondBase
  class Base < ActiveRecord::Base

    self.abstract_class = true
    establish_connection ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX][Rails.env]

  end
end
