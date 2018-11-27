namespace :db do
  namespace :second_base do
    task "drop:_unsafe" do
      SecondBase.on_base { Rake::Task['db:drop:_unsafe'].execute }
    end

    namespace :migrate do
      desc 'Resets SecondBase database using your migrations for the current environment'
      task :reset => ['db:second_base:drop:_unsafe', 'db:second_base:create', 'db:second_base:migrate']
    end
  end
end

%w{
  drop:_unsafe
}.each do |name|
  task = Rake::Task["db:#{name}"] rescue nil
  next unless task && SecondBase::Railtie.run_with_db_tasks?
  task.enhance do
    Rake::Task["db:load_config"].invoke
    Rake::Task["db:second_base:#{name}"].invoke
  end
end
