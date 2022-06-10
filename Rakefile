require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/testtask"

RSpec::Core::RakeTask.new(:spec)

Rake::TestTask.new do |t|
    t.test_files = FileList['tests/**/*_test.rb'] #my directory to tests is 'tests' you can change at you will
end
desc "Run tests"

task default: :spec

task :test
