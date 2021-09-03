namespace :db do
  namespace :second_base do

    namespace :create do
      desc 'Creates ALL DBs configured for Second base' unless SecondBase::Railtie.run_with_db_tasks?
      task :all => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:create:all'].execute }
      end
    end

    desc 'Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:secondbase:create:all to create all databases in the config). Without RAILS_ENV it defaults to creating the development and test databases.' unless SecondBase::Railtie.run_with_db_tasks?
    task :create => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:create'].execute }
    end

    namespace :drop do
      desc 'Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:secondbase:drop:all to drop all databases in the config). Without RAILS_ENV it defaults to dropping the development and test databases.' unless SecondBase::Railtie.run_with_db_tasks?
      task :all => ['db:load_config']  do
        SecondBase.on_base { Rake::Task['db:drop:all'].execute }
      end
    end

    namespace :purge do
      desc 'Purges (empties) ALL DBs configured for Second base' unless SecondBase::Railtie.run_with_db_tasks?
      task :all => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:purge:all'].execute }
      end
    end

    desc 'Empty the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:secondbase:drop:all to drop all databases in the config). Without RAILS_ENV it defaults to purging the development and test databases.' unless SecondBase::Railtie.run_with_db_tasks?
    task :purge => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:purge'].execute }
    end

    desc 'Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog).' unless SecondBase::Railtie.run_with_db_tasks?
    task :migrate => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:migrate'].execute }
    end

    namespace :migrate do

      desc 'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).' unless SecondBase::Railtie.run_with_db_tasks?
      task :redo => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:redo'].execute }
      end

      desc 'Runs the "up" for a given migration VERSION.'
      task :up => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:up'].execute }
      end

      desc 'Runs the "down" for a given migration VERSION.'
      task :down => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:down'].execute }
      end

      desc 'Display status of migrations'
      task :status => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:status'].execute }
      end

    end

    desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
    task :rollback => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:rollback'].execute }
    end

    desc 'Drops and recreates the database from db/schema.rb for the current environment and loads the seeds.'
    task :forward => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:forward'].execute }
    end

    task :abort_if_pending_migrations do
      SecondBase.on_base { Rake::Task['db:abort_if_pending_migrations'].execute }
    end

    desc 'Retrieves the current schema version number'
    task :version => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:version'].execute }
    end

    namespace :schema do
      # desc 'Load a schema.rb file into the database' unless SecondBase::Railtie.run_with_db_tasks?
      task :load => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:schema:load'].execute }
      end

      namespace :cache do
        desc 'Create a db/schema_cache.dump file.' unless SecondBase::Railtie.run_with_db_tasks?
        task :dump => ['db:load_config'] do
          SecondBase.on_base { Rake::Task['db:schema:cache:dump'].execute }
        end

      end

    end

    namespace :structure do
      # desc 'Recreate the databases from the structure.sql file' unless SecondBase::Railtie.run_with_db_tasks?
      task :load => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:structure:load'].execute }
      end

      # desc 'Dumps the databases to structure.sql file'
      task :dump => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:structure:dump'].execute }
      end

    end

    namespace :test do
      desc 'Empty the test database' unless SecondBase::Railtie.run_with_db_tasks?
      task :purge => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:test:purge'].execute }
      end

      # desc 'Recreate the test database from an existent schema.rb file' unless SecondBase::Railtie.run_with_db_tasks?
      task :load_schema => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:test:load_schema'].execute }
      end

      # desc 'Recreate the test database from the current schema' unless SecondBase::Railtie.run_with_db_tasks?
      task :load_structure => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:test:load_structure'].execute }
      end

      desc 'Check for pending migrations and load the test schema' unless SecondBase::Railtie.run_with_db_tasks?
      task :prepare => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:test:prepare'].execute }
      end

    end

  end
end

%w{
  create:all create drop:all purge:all purge
  migrate migrate:status abort_if_pending_migrations
  schema:load schema:cache:dump structure:load structure:dump
  test:purge test:load_schema test:load_structure test:prepare
}.each do |name|
  task = Rake::Task["db:#{name}"] rescue nil
  next unless task && SecondBase::Railtie.run_with_db_tasks?
  task.enhance do
    Rake::Task["db:load_config"].invoke
    Rake::Task["db:second_base:#{name}"].invoke
  end
end
