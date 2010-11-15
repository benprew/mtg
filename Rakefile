require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new() do |t|
  t.rspec_opts = ["-Ilib" ]
end

namespace :db do
  namespace :test do
    desc "prepare test db"
    task :prepare do
      `rm /tmp/mtg_test_db`
      puts `sqlite3 /tmp/mtg_test_db < config/schema.sql`
      puts `sequel -m migrations sqlite:///tmp/mtg_test_db`
    end
  end

  task :migrate do
    puts `sequel -e #{ENV['RACK_ENV']} -m migrations config/database.yml `
  end
end

task :spec => [ :'db:test:prepare' ]

task :default => :spec
