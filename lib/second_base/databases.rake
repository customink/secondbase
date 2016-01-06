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

Rake::Task['db:create'].enhance { Rake::Task['second_base:create'].invoke }
Rake::Task['db:migrate'].enhance { Rake::Task['second_base:migrate'].invoke }
Rake::Task['db:drop'].enhance { Rake::Task['second_base:drop'].invoke }
Rake::Task['db:test:purge'].enhance { Rake::Task['second_base:test:purge'].invoke }
Rake::Task['db:schema:load'].enhance { Rake::Task['second_base:schema:load'].invoke }
Rake::Task['db:structure:load'].enhance { Rake::Task['second_base:structure:load'].invoke }
Rake::Task['db:test:load_schema'].enhance { Rake::Task['second_base:test:load_schema'].invoke }
Rake::Task['db:abort_if_pending_migrations'].enhance { Rake::Task['second_base:abort_if_pending_migrations'].invoke }
Rake::Task['db:test:load_structure'].enhance { Rake::Task['second_base:test:load_structure'].invoke }
