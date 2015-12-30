module SecondBase
  class Railtie < Rails::Railtie

    rake_tasks do
      load 'secondbase/databases.rake'
    end

  end
end
