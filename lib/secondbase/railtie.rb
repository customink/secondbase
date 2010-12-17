require 'secondbase'
require 'rails'
module SecondBase
  class Railtie < Rails::Railtie

    rake_tasks do
      load "tasks.rb"
    end
  end
end
