require 'rails'
require 'active_record'
require 'secondbase/version'
require 'secondbase/active_record/base'
require 'secondbase/active_record/associations/has_and_belongs_to_many_association'
require 'secondbase/force_secondbase'
require 'secondbase/rake_method_chain'

module SecondBase

  CONNECTION_PREFIX = 'secondbase'

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
