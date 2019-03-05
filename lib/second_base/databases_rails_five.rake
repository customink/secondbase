db_namespace = namespace :db do
  namespace :second_base do
    task "drop:_unsafe" do
      SecondBase.on_base { db_namespace['drop:_unsafe'].execute }
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
  task = db_namespace[name] rescue nil
  next unless task && SecondBase::Railtie.run_with_db_tasks?
  task.enhance do
    db_namespace["load_config"].invoke
    db_namespace["second_base:#{name}"].invoke
  end
end
