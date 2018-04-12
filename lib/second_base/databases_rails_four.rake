namespace :db do
  namespace :second_base do
    task :drop do
      SecondBase.on_base { Rake::Task['db:drop'].execute }
    end

    namespace :migrate do
      task :reset => ['db:second_base:drop', 'db:second_base:create', 'db:second_base:migrate']
    end
  end
end
