module ThirdBase
  class Railtie < Rails::Railtie

    config.third_base = ActiveSupport::OrderedOptions.new
    config.third_base.path = 'db/thirdbase'
    config.third_base.config_key = 'thirdbase'
    config.third_base.run_with_db_tasks = true

    config.after_initialize do |app|
      thirdbase_dir = app.root.join(config.third_base.path)
      FileUtils.mkdir(thirdbase_dir) unless File.directory?(thirdbase_dir)
    end

    rake_tasks do
      load 'third_base/databases.rake'
      
      if Rails.version.to_i == 4
        load 'third_base/databases_rails_four.rake'
      else
        load 'third_base/databases_rails_five.rake'
      end

    end

    generators do
      require 'rails/third_base/generators/migration_generator'
    end

    initializer 'third_base.add_watchable_files' do |app|
      thirdbase_dir = app.root.join(config.third_base.path)
      config.watchable_files.concat ["#{thirdbase_dir}/schema.rb", "#{thirdbase_dir}/structure.sql"]
    end

    initializer 'third_base.check_schema_cache_dump', after: 'active_record.check_schema_cache_dump' do |app|
      use_cache  = config.active_record.use_schema_cache_dump
      cache_file = app.root.join(config.third_base.path, 'schema_cache.dump')
      if use_cache && File.file?(cache_file)
        cache = Marshal.load File.binread(cache_file)
        ThirdBase::Base.connection.schema_cache = cache
      end
    end

    def config_path
      config.third_base.path
    end

    def config_key
      config.third_base.config_key
    end

    def run_with_db_tasks?
      config.third_base.run_with_db_tasks
    end

    def paths
      @paths ||= [fullpath('migrate')]
    end

    def paths=(val)
      @paths = val
    end

    def fullpath(extra=nil)
      path = Rails.root.join(config.third_base.path)
      (extra ? path.join(path, extra) : path).to_s
    end

  end
end
