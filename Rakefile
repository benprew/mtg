require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new() do |t|
  t.rspec_opts = ["-Ilib" ]
end

task :default => :spec

