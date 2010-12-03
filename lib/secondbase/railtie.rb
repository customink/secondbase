require 'secondbase'
require 'rails'
module SecondBase
  class Railtie < Rails::Railtie

    rake_tasks do
      load "tasks/secondbase.rake"
    end
  end
end
