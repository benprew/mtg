require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.libs = ['lib/mtg']
  t.spec_opts = ["--diff", 'u']
end

desc "Print specdocs"
Spec::Rake::SpecTask.new(:doc) do |t|
  t.spec_opts = ["--format", "specdoc", "--dry-run"]
  t.spec_files = FileList['spec/*_spec.rb']
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'examples']
end

namespace :db do
  namespace :test do
    desc "prepare test db"
    task :prepare do
      `sqlite3 /tmp/mtg_test_db < config/schema.sql`
    end
  end
end

task :spec => [ :'db:test:prepare' ]

task :default => :spec
