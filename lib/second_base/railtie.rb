module SecondBase
  class Railtie < Rails::Railtie

    config.second_base = ActiveSupport::OrderedOptions.new
    config.second_base.path = 'db/secondbase'
    config.second_base.config_key = 'secondbase'

    config.after_initialize do |app|
      path = config.second_base.path
      pdir = app.root.join(path)
      FileUtils.mkdir(pdir) unless File.directory?(pdir)
      app.paths.add(path)
    end

    rake_tasks do
      load 'second_base/databases.rake'
    end

    def config_key
      Rails.application.config.second_base.config_key
    end

    def fullpath(extra=nil)
      path = Rails.application.config.paths[config.second_base.path].first
      extra ? File.join(path, extra) : path
    end

  end
end
