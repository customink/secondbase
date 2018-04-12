namespace :db do
  namespace :third_base do
    task "drop:_unsafe" do
      ThirdBase.on_base { Rake::Task['db:drop:_unsafe'].execute }
    end

    namespace :migrate do
      task :reset => ['db:third_base:drop:_unsafe', 'db:third_base:create', 'db:third_base:migrate']
    end
  end
end
