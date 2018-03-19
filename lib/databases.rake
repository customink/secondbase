def enhance_task_if_present(name)
  task = Rake::Task["db:#{name}"] rescue nil
  return unless task

  extend_namespace_task(task, SecondBase, name)
  extend_namespace_task(task, ThirdBase, name)
end

def extend_namespace_task(task, namespace, name)
  if namespace::Railtie.run_with_db_tasks?
    task.enhance do
      unless SecondBase.is_on_base || ThirdBase.is_on_base
        Rake::Task["db:load_config"].invoke
        Rake::Task["db:#{namespace.name.underscore}:#{name}"].invoke
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
  enhance_task_if_present(name)
end
if Rails.version.to_i == 4
  %w{
    drop
  }.each do |name|
    enhance_task_if_present(name)
  end
else
  %w{
    drop:_unsafe
  }.each do |name|
    enhance_task_if_present(name)
  end
end
