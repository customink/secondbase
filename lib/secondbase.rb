require 'second_base'
require 'third_base'

class SecondBaseRailtie < Rails::Railtie
  rake_tasks do
    load 'databases.rake'
  end
end
