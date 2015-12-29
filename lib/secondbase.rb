require 'active_record'
require 'secondbase/version'
require 'secondbase/active_record/base'
require 'secondbase/active_record/associations/has_and_belongs_to_many_association'
require 'secondbase/force_secondbase'

module SecondBase
  CONNECTION_PREFIX = 'secondbase'

  require 'secondbase/railtie' if defined?(Rails)
  require 'secondbase/rake_method_chain'

  def self.has_runner(env)
    ActiveRecord::Base.establish_connection(SecondBase::config(env))
    reset_visitor_cache
  end

  def self.config(env)
    ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX][env]
  end

  # TODO: We should really look at faking out the connection used by ActiveRecord
  # during migrations, this would prevent us from digging around Arel internals.
  # Arel caches the SQL translator based on the engine (ActiveRecord::Base).  This
  # means that if we swap out the base connection we risk the SQL translator being wrong.
  # This is an ugly hack that resets the adapter.  See Line 27 of Arel's visitors.rb class.
  def self.reset_visitor_cache
    engine = ActiveRecord::Base
    Arel::Visitors::ENGINE_VISITORS[engine] = engine.connection.visitor
  end
end

module FirstBase
  def self.config(env)
    ActiveRecord::Base.configurations[env]
  end

  def self.has_runner(env)
    ActiveRecord::Base.establish_connection(FirstBase::config(env))
    SecondBase.reset_visitor_cache
  end
end
