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
  namespace :migrate do
    desc "migrates the second database"
    task :secondbase => :load_config do
      Rake::Task['environment'].invoke
      # NOTE: We are not generating a db schema on purpose.  Since we're running 
      # in a dual db mode, it could be confusing to have two schemas.
      
      # reset connection to secondbase...
      use_secondbase(Rails.env)
      
      # run secondbase migrations...
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("db/migrate/#{SecondBase::CONNECTION_PREFIX}/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      
      # reset connection back to firstbase...
      use_firstbase(Rails.env)
    end
    
    namespace :up do
      desc 'Runs the "up" for a given SecondBase migration VERSION.'
      task :secondbase => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        
        # reset connection to secondbase...
        use_secondbase(Rails.env)
        
        ActiveRecord::Migrator.run(:up, "db/migrate/#{SecondBase::CONNECTION_PREFIX}/", version)
        
        # reset connection back to firstbase...
        use_firstbase(Rails.env)
      end
    end
    
    namespace :down do
      desc 'Runs the "down" for a given SecondBase migration VERSION.'
      task :secondbase => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        
        # reset connection to secondbase...
        use_secondbase(Rails.env)
        
        ActiveRecord::Migrator.run(:down, "db/migrate/#{SecondBase::CONNECTION_PREFIX}/", version)
        
        # reset connection back to firstbase...
        use_firstbase(Rails.env)
      end
    end
  end
  
  namespace :create do
    desc 'Create the database defined in config/database.yml for the current RAILS_ENV'
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
        
        # we want to dump the development (second)database....
        use_secondbase('development')
        
        File.open("#{RAILS_ROOT}/db/#{SecondBase::CONNECTION_PREFIX}_#{RAILS_ENV}_structure.sql", "w+") do |f| 
          f << ActiveRecord::Base.connection.structure_dump
        end
        
        use_firstbase(Rails.env)
      end 
    end
  end

  namespace :test do
    namespace :prepare do
      desc 'Prepares the test instance of secondbase'
      task :secondbase do
        Rake::Task["db:test:clone_structure:secondbase"].invoke
      end
    end
    
    namespace :purge do
      task :secondbase do
        Rake::Task['environment'].invoke    
        
        use_secondbase('test')
        
        ActiveRecord::Base.connection.recreate_database(secondbase_config('test')["database"], secondbase_config('test')) 
        
        use_firstbase(Rails.env)
      end
    end

    namespace :clone_structure do
      task :secondbase do
        Rake::Task['environment'].invoke
        
        # dump secondbase structure and purge the test secondbase
        `rake db:structure:dump:secondbase`
        `rake db:test:purge:secondbase`

        # now lets clone the structure for secondbase
        use_secondbase('test')
        ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0')
        IO.readlines("#{RAILS_ROOT}/db/#{SecondBase::CONNECTION_PREFIX}_#{RAILS_ENV}_structure.sql").join.split("\n\n").each do |table|
          ActiveRecord::Base.connection.execute(table)
        end
        
        use_firstbase(Rails.env)
      end
    end
  end

end


####################################
# 
# Some helper methods to run back and forth between first and second base.
def use_firstbase(env)
  ActiveRecord::Base.establish_connection(firstbase_config(env))
end

def use_secondbase(env)
  ActiveRecord::Base.establish_connection(secondbase_config(env))
end

def secondbase_config(env)
  ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX][env]
end

def firstbase_config(env)
  ActiveRecord::Base.configurations[env]
end