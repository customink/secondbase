require 'secondbase'

db_namespace = namespace :db do
  desc '[SECONDBASE] Drops your local databases'
  override_task :drop => [:load_config] do
    Rake::Task['db:drop:original'].invoke
    Rake::Task['secondbase:drop'].invoke
  end
  
  desc '[SECONDBASE] Creates your local databases'
  override_task :create => [:load_config] do
    Rake::Task['db:create:original'].invoke
    Rake::Task['secondbase:create'].invoke
  end
  
  desc '[SECONDBASE] Migrates your local databases'
  override_task :migrate => [:load_config] do
    Rake::Task['db:migrate:original'].invoke
    Rake::Task['secondbase:migrate'].invoke
  end
  
  desc '[SECONDBASE] Check if thier are pending migrations across both databases'
  override_task :abort_if_pending_migrations => [:environment, :load_config] do
    Rake::Task['db:abort_if_pending_migrations:original'].invoke
    Rake::Task['secondbase:abort_if_pending_migrations'].invoke
  end
  
  namespace :structure do
    desc '[SECONDBASE] Dump the database structures to disk'
    override_task :dump => [:environment, :load_config] do
      Rake::Task['db:structure:dump:original'].invoke
      Rake::Task['secondbase:structure:dump'].invoke
    end
    
    desc '[SECONDBASE] Loads the database structures from disk'
    override_task :load => [:environment, :load_config] do
      Rake::Task['db:structure:load:original'].invoke
      Rake::Task['secondbase:structure:load'].invoke
    end
  end
  
  namespace :test do
    desc '[SECONDBASE] Dump the database structures to disk'
    override_task :purge => [:environment, :load_config] do
      Rake::Task['db:test:purge:original'].invoke
      Rake::Task['secondbase:test:purge'].invoke
    end
  end  
end

namespace :secondbase do  
  desc 'Drops the second database'
  task :drop do
    for_all_local do |c|
      ActiveRecord::Tasks::DatabaseTasks.drop c
    end
  end
  
  desc 'Creates the second database'
  task :create do
    for_all_local do |c|
      ActiveRecord::Tasks::DatabaseTasks.create c
    end
  end
  
  desc 'Migrate the second database' 
  task migrate: %w(environment db:load_config) do
    migration_path = DatabaseTasks.db_dir+ "/#{SecondBase::CONNECTION_PREFIX}/"
    on_secondbase do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(migration_path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end 
  end
  
  task :up do
    migration_path = DatabaseTasks.db_dir+ "/#{SecondBase::CONNECTION_PREFIX}/"
    
    on_secondbase do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      
      ActiveRecord::Migrator.run(:down, migration_path, version)
    end
  end
  
  task :down do
    migration_path = DatabaseTasks.db_dir+ "/#{SecondBase::CONNECTION_PREFIX}/"
    
    on_secondbase do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      
      ActiveRecord::Migrator.run(:down, migration_path, version)
    end
  end
  
  task :abort_if_pending_migrations do
    migration_path = DatabaseTasks.db_dir+ "/#{SecondBase::CONNECTION_PREFIX}/"
    
    on_secondbase do
      pending_migrations = ActiveRecord::Migrator.new(:up, migration_path).pending_migrations
      if pending_migrations.any?
        puts "You have #{pending_migrations.size} secondbase pending migrations:"
        pending_migrations.each do |pending_migration|
          puts '  %4d %s' % [pending_migration.version, pending_migration.name]
        end
        abort %{Run "rake db:migrate" to update your database then try again.}
      end
    end
  end
  
  namespace :structure do
    desc 'Dump the second development structure to disk'
    task dump: %w(environment db:load_config) do
      filename = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "secondbase_structure.sql")
      ActiveRecord::Tasks::DatabaseTasks.structure_dump(secondbase_config, filename)
      on_secondbase do
        if ActiveRecord::Base.connection.supports_migrations? && ActiveRecord::SchemaMigration.table_exists?
          File.open(filename, "a") do |f|
            f.puts ActiveRecord::Base.connection.dump_schema_information
            f.print "\n"
          end
        end
      end
    end
    
    desc 'Load the second development structure from disk'
    task load: %w(environment db:load_config) do
      filename = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "secondbase_structure.sql")
      ActiveRecord::Tasks::DatabaseTasks.structure_load(secondbase_config, filename)
    end
  end
  
  namespace :test do
    desc 'Purge the second database'
    task purge: %w(environment db:load_config) do
      on_secondbase('test') do
        ActiveRecord::Base.connection.recreate_database(secondbase_config('test')['database'], secondbase_config('test'))
      end
    end
    
    desc 'Load the second database to test' 
    task :load_structure do
      filename = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "secondbase_structure.sql")
      ActiveRecord::Tasks::DatabaseTasks.structure_load(secondbase_config('test'), filename)
    end
  end
end

def secondbase_config(env = Rails.env)
  ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX][env]
end

def local_database?(configuration)
  configuration['host'].blank? || ActiveRecord::Tasks::DatabaseTasks::LOCAL_HOSTS.include?(configuration['host'])
end

def for_all_local
  ActiveRecord::Base.configurations[SecondBase::CONNECTION_PREFIX].each do |c|
    env, config = *c
    next unless config['database']
    if local_database?(config)
       yield config
     else
       $stderr.puts "This task only modifies local databases. #{config['database']} is on a remote host."
     end
   end
end

def on_secondbase(env = Rails.env)
  SecondBase::has_runner(Rails.env)
  yield
  FirstBase::has_runner(Rails.env)
end

