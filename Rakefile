require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

desc 'Default: run specs and features'
task :default => :test

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb' # don't need this; it's default.
  # Put spec opts in a file named .rspec in root
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty -s"
end

Cucumber::Rake::Task.new(:features_ci) do |t|
  t.cucumber_opts = "--format progress"
end

desc 'Run specs and features'
task :test => [:spec, :features_ci]
