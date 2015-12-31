module SecondBase
  class Railtie < Rails::Railtie

    config.second_base = ActiveSupport::OrderedOptions.new
    config.second_base.path = 'db/secondbase'

    config.after_initialize do |app|
      path = config.second_base.path
      pdir = app.root.join(path)
      FileUtils.mkdir(pdir) unless File.directory?(pdir)
      app.paths.add(path)
    end

    rake_tasks do
      load 'second_base/databases.rake'
    end

  end
end
