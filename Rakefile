require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ['lib','test']
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

desc "Bootstrap development/test DB setup."
task :bootstrap do
  # ENV['DATBASE_URL'] = 'mysql://root@localhost/secondbase_url'
  require_relative './test/dummy_app/init'
  require_relative './test/test_helpers/dummy_app_helpers'
  include SecondBase::DummyAppHelpers
  # dummy_root = File.expand_path "#{__dir__}/test/dummy_app"
  Dir.chdir(dummy_root) { `rake db:create` }
  delete_dummy_files
end

task :default do
  Kernel.system 'appraisal update'
  Kernel.system 'appraisal rake test'
end
