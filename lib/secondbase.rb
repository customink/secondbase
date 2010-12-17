require 'active_record'

module SecondBase
  CONNECTION_PREFIX = 'secondbase'
  
  require 'secondbase/railtie' if Rails::VERSION::MAJOR == 3
  require 'secondbase/rake_method_chain'
  
  def self.do
    "You have just gotten to SecondBase, my friend."
  end
  
  def self.has_runner(env)
    ActiveRecord::Base.establish_connection(SecondBase::config(env))
  end

  def self.config(env)
    ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX][env]
  end

end

module FirstBase
  def self.config(env)
    ActiveRecord::Base.configurations[env]
  end
  
  def self.has_runner(env)
    ActiveRecord::Base.establish_connection(FirstBase::config(env))
  end
end
