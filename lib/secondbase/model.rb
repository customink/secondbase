# Secondbase model definition
#
# NOTE: By extending this model, you assume that the underlying table will be located in your Second (Data)base
module SecondBase
  
  class Base < ActiveRecord::Base
    establish_connection ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX][Rails.env]
  
    self.abstract_class = true
  end
end