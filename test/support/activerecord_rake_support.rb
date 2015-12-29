unless defined?(Rails)
  module Rails
    def self.root
      File.expand_path __dir__ + '/../fixtures'
    end

    def self.env
      ActiveSupport::StringInquirer.new(ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development')
    end
  end
end

include ActiveRecord::Tasks

DatabaseTasks.database_configuration = YAML.load(File.read(File.join(Rails.root, 'config/database.yml')))
DatabaseTasks.db_dir = File.join Rails.root, 'db'
DatabaseTasks.migrations_paths = [File.join(Rails.root, 'db/migrate')]
DatabaseTasks.env = Rails.env

ActiveRecord::Base.configurations = DatabaseTasks.database_configuration

module RakeTestSetup
  def setup_rake
    require 'rake'
    Rake.application = Rake::Application.new
    Rake::Task.define_task :environment do
      ActiveRecord::Base.establish_connection DatabaseTasks.env
    end
    load Gem.find_files('active_record/railties/databases.rake').first
    load Gem.find_files('secondbase/tasks.rb').first
  end
end
