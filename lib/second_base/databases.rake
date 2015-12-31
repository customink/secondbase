namespace :second_base do

  task :load_config do
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = SecondBase::Railtie.fullpath + '/migrate'
    ActiveRecord::Tasks::DatabaseTasks.db_dir = SecondBase::Railtie.fullpath
  end

  task migrate: [:load_config] do
    SecondBase.on_base do
      Rake::Task['db:migrate'].execute
     end
  end

end

Rake::Task['db:migrate'].enhance { Rake::Task['second_base:migrate'].invoke }
