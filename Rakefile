require "bundler/gem_tasks"
require "rspec/core/rake_task"

# RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[-c -f progress -r ./spec/spec_helper.rb]
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

task :default => :spec
