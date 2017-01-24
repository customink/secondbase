module SecondBase
  class Railtie < Rails::Railtie

    config.second_base = ActiveSupport::OrderedOptions.new
    config.second_base.path = 'db/secondbase'
    config.second_base.config_key = 'secondbase'
    config.second_base.run_with_db_tasks = true

    config.after_initialize do |app|
      secondbase_dir = app.root.join(config.second_base.path)
      FileUtils.mkdir(secondbase_dir) unless File.directory?(secondbase_dir)
    end

    rake_tasks do
      load 'second_base/databases.rake'
      
      if Rails.version.to_i == 4
        load 'second_base/databases_rails_four.rake'
      else
        load 'second_base/databases_rails_five.rake'
      end

    end

    generators do
      require 'rails/second_base/generators/migration_generator'
    end

    initializer 'second_base.add_watchable_files' do |app|
      secondbase_dir = app.root.join(config.second_base.path)
      config.watchable_files.concat ["#{secondbase_dir}/schema.rb", "#{secondbase_dir}/structure.sql"]
    end

    initializer 'second_base.check_schema_cache_dump', after: 'active_record.check_schema_cache_dump' do |app|
      use_cache  = config.active_record.use_schema_cache_dump
      cache_file = app.root.join(config.second_base.path, 'schema_cache.dump')
      if use_cache && File.file?(cache_file)
        cache = Marshal.load File.binread(cache_file)
        SecondBase::Base.connection.schema_cache = cache
      end
    end

    def config_path
      config.second_base.path
    end

    def config_key
      config.second_base.config_key
    end

    def run_with_db_tasks?
      config.second_base.run_with_db_tasks
    end

    def fullpath(extra=nil)
      path = Rails.root.join(config.second_base.path)
      (extra ? path.join(path, extra) : path).to_s
    end

  end
end
