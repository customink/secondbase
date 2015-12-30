module SecondBase
  class Railtie < Rails::Railtie

    config.secondbase = ActiveSupport::OrderedOptions.new
    config.secondbase.path = 'db/secondbase'

    config.after_initialize do |app|
      path = config.secondbase.path
      pdir = app.root.join(path)
      FileUtils.mkdir(pdir) unless File.directory?(pdir)
      app.paths.add(path)
    end

    rake_tasks do
      load 'secondbase/databases.rake'
    end

  end
end
