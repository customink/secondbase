require 'secondbase'

####################################
#
# SecondBase database managment tasks
#
# We are overriding a handful of rake tasks here:
# db:create
# db:migrate
# db:test:prepare
#
# We ARE NOT redefining the implementation of these tasks, we are simply
# appending custom functionality to them. We just want to be sure that in
# addition to creating, migrating, and preparing your default (Rails.env)
# database, that we can also work with with the second (data)base.

namespace :db do
  override_task :create do
    # First, we execute the original/default create task
    Rake::Task["db:create:original"].invoke

    # now, we create our secondary databases
    Rake::Task['environment'].invoke
    ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX].each_value do |config|
      next unless config['database']

      # Only connect to local databases
      local_database?(config) { create_database(config) }
    end
  end

  override_task :migrate do
    Rake::Task['environment'].invoke

    # Migrate secondbase...
    Rake::Task["db:migrate:secondbase"].invoke

    # Execute the original/default prepare task
    Rake::Task["db:migrate:original"].invoke
  end

  override_task :abort_if_pending_migrations do
    # Execute the original/default prepare task
    Rake::Task["db:abort_if_pending_migrations"].invoke

    Rake::Task["db:abort_if_pending_migrations:secondbase"].invoke
  end

  namespace :test do
    override_task :prepare do
      Rake::Task['environment'].invoke

      # Clone the secondary database structure
      Rake::Task["db:test:prepare:secondbase"].invoke

      # Execute the original/default prepare task
      Rake::Task["db:test:prepare:original"].invoke
    end
  end

  ##################################
  # SecondBase specific database tasks
  namespace :abort_if_pending_migrations do
    desc "determines if your secondbase has pending migrations"
    task :secondbase => :environment do
      # reset connection to secondbase...
      SecondBase::has_runner(Rails.env)

      pending_migrations = ActiveRecord::Migrator.new(:up, "db/#{SecondBase::CONNECTION_PREFIX}/").pending_migrations

      if pending_migrations.any?
        puts "You have #{pending_migrations.size} pending migrations:"
        pending_migrations.each do |pending_migration|
          puts '  %4d %s' % [pending_migration.version, pending_migration.name]
        end
        abort %{Run "rake db:migrate" to update your database then try again.}
      end

      # reset connection back to firstbase...
      FirstBase::has_runner(Rails.env)
    end
  end

  namespace :rollback do
    desc "rolls back the second database"
    task :secondbase => [:environment, :load_config] do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      Rake::Task['environment'].invoke
      # NOTE: We are not generating a db schema on purpose.  Since we're running
      # in a dual db mode, it could be confusing to have two schemas.

      # reset connection to secondbase...
      SecondBase::has_runner(Rails.env)

      # run secondbase migrations...
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.rollback("db/#{SecondBase::CONNECTION_PREFIX}/", step)

      # reset connection back to firstbase...
      FirstBase::has_runner(Rails.env)
    end
  end

  namespace :migrate do
    desc "migrates the second database"
    task :secondbase => :load_config do
      Rake::Task['environment'].invoke
      # NOTE: We are not generating a db schema on purpose.  Since we're running
      # in a dual db mode, it could be confusing to have two schemas.

      # reset connection to secondbase...
      SecondBase::has_runner(Rails.env)

      # run secondbase migrations...
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("db/#{SecondBase::CONNECTION_PREFIX}/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)

      # reset connection back to firstbase...
      FirstBase::has_runner(Rails.env)
    end

    namespace :up do
      desc 'Runs the "up" for a given SecondBase migration VERSION.'
      task :secondbase => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version

        # reset connection to secondbase...
        SecondBase::has_runner(Rails.env)

        ActiveRecord::Migrator.run(:up, "db/#{SecondBase::CONNECTION_PREFIX}/", version)

        # reset connection back to firstbase...
        FirstBase::has_runner(Rails.env)
      end
    end

    namespace :down do
      desc 'Runs the "down" for a given SecondBase migration VERSION.'
      task :secondbase => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version

        # reset connection to secondbase...
        SecondBase::has_runner(Rails.env)

        ActiveRecord::Migrator.run(:down, "db/#{SecondBase::CONNECTION_PREFIX}/", version)

        # reset connection back to firstbase...
        FirstBase::has_runner(Rails.env)
      end
    end
  end

  namespace :create do
    desc 'Create the database defined in config/database.yml for the current Rails.env'
    task :secondbase => :load_config do

      # We can still use the #create_database method defined in activerecord's databases.rake
      # we call it passing the secondbase config instead of the default (Rails.env) config...
      create_database(secondbase_config(Rails.env))
    end
  end

  namespace :structure do
    namespace :dump do
      desc "dumps structure for both (first and second) databases."
      task :secondbase do
        Rake::Task['environment'].invoke

        SecondBase::has_runner(Rails.env)

        # dump the current env's db, be sure to add the schema information!!!
        dump_file = "#{Rails.root}/db/#{SecondBase::CONNECTION_PREFIX}_#{Rails.env}_structure.sql"

        File.open(dump_file, "w+") do |f|
          f << ActiveRecord::Base.connection.structure_dump
        end

        if ActiveRecord::Base.connection.supports_migrations?
          File.open(dump_file, "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
        end

        FirstBase::has_runner(Rails.env)
      end
    end
  end

  namespace :test do
    namespace :prepare do
      desc 'Prepares the test instance of secondbase'
      task :secondbase => 'db:abort_if_pending_migrations:secondbase' do
        Rake::Task["db:test:clone_structure:secondbase"].invoke
      end
    end

    namespace :purge do
      task :secondbase do
        Rake::Task['environment'].invoke

        SecondBase::has_runner('test')
        
        case secondbase_config('test')["adapter"]
        when "mysql"
          ActiveRecord::Base.connection.recreate_database(secondbase_config('test')["database"], secondbase_config('test'))
        when "oracle_enhanced"
          ActiveRecord::Base.connection.execute_structure_dump(ActiveRecord::Base.connection.full_drop)
        end
        
        FirstBase::has_runner(Rails.env)
      end
    end

    namespace :clone_structure do
      task :secondbase do
        Rake::Task['environment'].invoke

        # dump secondbase structure and purge the test secondbase
        `rake db:structure:dump:secondbase`
        `rake db:test:purge:secondbase`

        # now lets clone the structure for secondbase
        SecondBase::has_runner('test')

        ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0') if secondbase_config(Rails.env)['adapter'][/mysql/]

        IO.readlines("#{Rails.root}/db/#{SecondBase::CONNECTION_PREFIX}_#{Rails.env}_structure.sql").join.split("\n\n").each do |table|
          ActiveRecord::Base.connection.execute(table)
        end

        FirstBase::has_runner(Rails.env)
      end
    end
  end

end


####################################
#
# Some helper methods to run back and forth between first and second base.
def secondbase_config(env)
  ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX][env]
end
