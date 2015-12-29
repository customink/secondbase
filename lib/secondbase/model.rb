# Secondbase model definition
#
# NOTE: By extending this model, you assume that the underlying table will be located in your Second (Data)base
module SecondBase
  class Base < ActiveRecord::Base

    self.abstract_class = true
    establish_connection ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX][Rails.env]

  end
end
