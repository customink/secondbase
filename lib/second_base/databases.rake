namespace :second_base do

  task :load_config do
  end

  task migrate: [:load_config] do
    SecondBase.on_base do
      Rake::Task['db:migrate'].execute
     end
  end

  task create: [:load_config] do
    SecondBase.on_base { Rake::Task['db:create'].execute }
  end

  task drop: [:load_config] do
    SecondBase.on_base { Rake::Task['db:drop'].execute }
  end

  namespace :test do

    task purge: [:load_config] do
      SecondBase.on_base { Rake::Task['db:test:purge'].execute }
    end

    task load_schema: [:load_config] do
      SecondBase.on_base { Rake::Task['db:test:load_schema'].execute }
    end

    task load_structure: [:load_config] do
      SecondBase.on_base { Rake::Task['db:test:load_structure'].execute }
    end

  end

end

Rake::Task['db:create'].enhance { Rake::Task['second_base:create'].invoke }
Rake::Task['db:migrate'].enhance { Rake::Task['second_base:migrate'].invoke }
Rake::Task['db:drop'].enhance { Rake::Task['second_base:drop'].invoke }
Rake::Task['db:test:purge'].enhance { Rake::Task['second_base:test:purge'].invoke }
Rake::Task['db:test:load_schema'].enhance { Rake::Task['second_base:test:load_schema'].invoke }
Rake::Task['db:test:load_structure'].enhance { Rake::Task['second_base:test:load_structure'].invoke }
