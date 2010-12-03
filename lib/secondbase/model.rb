# Secondbase model definition
#
# NOTE: By extending this model, you assume that the underlying table will be located in your Second (Data)base
module SecondBase
  require 'active_record'
  
  class Base < ActiveRecord::Base
    establish_connection ActiveRecord::Base.configurations[CONNECTION_PREFIX][Rails.env]
  
    self.abstract_class = true
  end
end