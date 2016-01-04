require 'rails'
require 'active_record'
require 'active_record/railtie'
require 'second_base/version'
require 'second_base/railtie'
require 'second_base/forced'

module SecondBase

  extend ActiveSupport::Autoload

  autoload :Base

  def self.config(env = nil)
    config = ActiveRecord::Base.configurations[config_name]
    config ? config[env || Rails.env] : nil
  end

  def self.config_name
    'secondbase'
  end

  def self.on_base
    original_config = ActiveRecord::Tasks::DatabaseTasks.current_config
    origional_configurations = ActiveRecord::Base.configurations
    origional_migrations_path = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    origional_db_dir = ActiveRecord::Tasks::DatabaseTasks.db_dir
    # Override for secondbase
    ActiveRecord::Base.configurations = origional_configurations[config_name]
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = SecondBase::Railtie.fullpath + '/migrate'
    ActiveRecord::Tasks::DatabaseTasks.db_dir = SecondBase::Railtie.fullpath

    yield
  ensure
    ActiveRecord::Base.configurations = origional_configurations
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = origional_migrations_path
    ActiveRecord::Tasks::DatabaseTasks.db_dir = origional_db_dir
    ActiveRecord::Base.establish_connection(original_config)
  end

end
