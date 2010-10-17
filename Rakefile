require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new() do |t|
  ENV['RACK_ENV'] = 'test'
  t.rspec_opts = ["-Ilib", "-c" ]
end

namespace :db do
  namespace :test do
    desc "prepare test db"
    task :prepare do
      puts `sqlite3 /tmp/mtg_test_db < config/schema.sql`
    end
  end
end

task :spec => [ :'db:test:prepare' ]

task :default => :spec
