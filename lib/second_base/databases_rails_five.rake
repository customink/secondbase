namespace :db do
  namespace :second_base do
    task "drop:_unsafe" do
      SecondBase.on_base { Rake::Task['db:drop:_unsafe'].execute }
    end

    namespace :migrate do
      task :reset => ['db:second_base:drop:_unsafe', 'db:second_base:create', 'db:second_base:migrate']
    end
  end
end
