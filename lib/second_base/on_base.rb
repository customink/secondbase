module SecondBase

  mattr_accessor :is_on_base, instance_accessor: false
  self.is_on_base = false

  def self.on_base
    already_on_base = is_on_base
    if already_on_base
      yield
      return
    end
    original_config = ActiveRecord::Tasks::DatabaseTasks.current_config
    original_configurations = Rails.application.config.database_configuration
    original_migrations_path = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    original_db_dir = ActiveRecord::Tasks::DatabaseTasks.db_dir
    ActiveRecord::Tasks::DatabaseTasks.current_config = config
    ActiveRecord::Base.configurations = original_configurations[Railtie.config_key]
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [SecondBase::Railtie.fullpath('migrate')]
    ActiveRecord::Tasks::DatabaseTasks.db_dir = SecondBase::Railtie.fullpath
    ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
    self.is_on_base = true
    yield
  ensure
    unless already_on_base
      ActiveRecord::Base.configurations = original_configurations
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths = original_migrations_path
      ActiveRecord::Tasks::DatabaseTasks.db_dir = original_db_dir
      ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
      ActiveRecord::Tasks::DatabaseTasks.current_config = original_config
      ActiveRecord::Base.establish_connection(original_config)
      self.is_on_base = false
    end
  end

end
