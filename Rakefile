require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new() do |t|
  t.rspec_opts = ["-Ilib" ]
end

task :test do
  ENV['RACK_ENV'] = 'test'
  require 'lib/mtg/sql_db'
end

namespace :db do
  task :migrate do
    puts `sequel -e #{ENV['RACK_ENV']} -m migrations config/database.yml `
  end
end

task :spec => [ :test, :'db:migrate' ]

task :default => :spec

