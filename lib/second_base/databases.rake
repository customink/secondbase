namespace :db do
  namespace :second_base do

    namespace :create do
      task :all do
        SecondBase.on_base { Rake::Task['db:create:all'].execute }
      end
    end

    task :create do
      SecondBase.on_base { Rake::Task['db:create'].execute }
    end

    namespace :drop do
      task :all do
        SecondBase.on_base { Rake::Task['db:drop:all'].execute }
      end
    end

    namespace :purge do
      task :all do
        SecondBase.on_base { Rake::Task['db:purge:all'].execute }
      end
    end

    task :purge do
      SecondBase.on_base { Rake::Task['db:purge'].execute }
    end

    task :migrate => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:migrate'].execute }
    end

    namespace :migrate do

      task :redo => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:redo'].execute }
      end

      task :up => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:up'].execute }
      end

      task :down => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:down'].execute }
      end

      task :status => ['db:load_config'] do
        SecondBase.on_base { Rake::Task['db:migrate:status'].execute }
      end

    end

    task :rollback => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:rollback'].execute }
    end

    task :forward => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:forward'].execute }
    end

    task :abort_if_pending_migrations do
      SecondBase.on_base { Rake::Task['db:abort_if_pending_migrations'].execute }
    end

    task :version => ['db:load_config'] do
      SecondBase.on_base { Rake::Task['db:version'].execute }
    end

    namespace :schema do

      task :load do
        SecondBase.on_base { Rake::Task['db:schema:load'].execute }
      end

      namespace :cache do

        task :dump do
          SecondBase.on_base { Rake::Task['db:schema:cache:dump'].execute }
        end

      end

    end

    namespace :structure do

      task :load do
        SecondBase.on_base { Rake::Task['db:structure:load'].execute }
      end

    end

    namespace :test do

      task :purge do
        SecondBase.on_base { Rake::Task['db:test:purge'].execute }
      end

      task :load_schema do
        SecondBase.on_base { Rake::Task['db:test:load_schema'].execute }
      end

      task :load_structure do
        SecondBase.on_base { Rake::Task['db:test:load_structure'].execute }
      end

      task :prepare do
        SecondBase.on_base { Rake::Task['db:test:prepare'].execute }
      end

    end

  end
end

%w{
  create:all create drop:all purge:all purge
  migrate migrate:status abort_if_pending_migrations
  schema:load schema:cache:dump structure:load
  test:purge test:load_schema test:load_structure test:prepare
}.each do |name|
  task = Rake::Task["db:#{name}"] rescue nil
  next unless task && SecondBase::Railtie.run_with_db_tasks?
  task.enhance do
    Rake::Task["db:load_config"].invoke
    Rake::Task["db:second_base:#{name}"].invoke
  end
end
