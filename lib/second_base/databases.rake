namespace :second_base do

  task :load_config do
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = SecondBase::Railtie.fullpath
  end

  task :migrate do
    SecondBase.on_base { Rake::Task['db:migrate'].execute }
  end

end

Rake::Task['db:migrate'].enhance { Rake::Task['second_base:migrate'].invoke }
