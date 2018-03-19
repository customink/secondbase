namespace :db do
  namespace :third_base do
    task :drop do
      ThirdBase.on_base { Rake::Task['db:drop'].execute }
    end

    namespace :migrate do
      task :reset => ['db:third_base:drop', 'db:third_base:create', 'db:third_base:migrate']
    end
  end
end
