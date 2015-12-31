require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'

module Secondbase
  class MigrationGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

     # Implement the required interface for Rails::Generators::Migration.
     # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
    def self.next_migration_number(dirname) #:nodoc:
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def create_migration_file
      migration_template 'migration.rb',
                          "db/migrate/#{SecondBase.config_name}/#{class_name.underscore}.rb",
                          :assigns => get_local_assigns
    end

    private
    # TODO: We need to add support for name/value pairs like title:string dob:date etc..
    def get_local_assigns
      { :class_name => class_name }
    end

  end
end
