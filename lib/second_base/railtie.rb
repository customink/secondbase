module SecondBase
  class Railtie < Rails::Railtie

    config.second_base = ActiveSupport::OrderedOptions.new
    config.second_base.path = 'db/secondbase'
    config.second_base.config_key = 'secondbase'

    config.after_initialize do |app|
      secondbase_dir = app.root.join(config.second_base.path)
      FileUtils.mkdir(secondbase_dir) unless File.directory?(secondbase_dir)
    end

    rake_tasks do
      load 'second_base/databases.rake'
    end

    generators do
      require 'rails/second_base/generators/migration_generator'
    end

    initializer 'second_base.add_watchable_files' do |app|
      secondbase_dir = app.root.join(config.second_base.path)
      config.watchable_files.concat ["#{secondbase_dir}/schema.rb", "#{secondbase_dir}/structure.sql"]
    end

    def config_path
      config.second_base.path
    end

    def config_key
      config.second_base.config_key
    end

    def fullpath(extra=nil)
      path = Rails.root.join(config.second_base.path)
      (extra ? path.join(path, extra) : path).to_s
    end

  end
end
