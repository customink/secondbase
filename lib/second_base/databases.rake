namespace :db do
  namespace :second_base do

    task :migrate do
      SecondBase.on_base { Rake::Task['db:migrate'].execute }
    end

    task :create do
      SecondBase.on_base { Rake::Task['db:create'].execute }
    end

    task :drop do
      SecondBase.on_base { Rake::Task['db:drop'].execute }
    end

    task :abort_if_pending_migrations do
      SecondBase.on_base { Rake::Task['db:abort_if_pending_migrations'].execute }
    end

    namespace :schema do

      task :load do
        SecondBase.on_base { Rake::Task['db:schema:load'].execute }
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

    end

  end
end

%w{
  migrate create drop abort_if_pending_migrations
  schema:load structure:load
  test:purge test:load_schema test:load_structure
}.each do |task|
  Rake::Task["db:#{task}"].enhance do
    Rake::Task["db:second_base:#{task}"].invoke
  end
end
