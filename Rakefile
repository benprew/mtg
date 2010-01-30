require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
	t.spec_files = FileList['spec/*_spec.rb']
  t.libs = ['lib/mtg']
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

task :default => :spec

######################################################

$ruby         = `which ruby`.chomp
$pid_file     = '/var/run/mtg'
$server       = 'mongrel'
$environment  = 'production'
$executable   = 'mtg.rb'
$executable_dir = Dir.pwd
$port         = 10000

desc 'Install mtg as a daemon and run it at boot.'
task :daemonize => 'daemon:at_boot' do
  sh '/etc/init.d/mtg start' do |successful, _|
    if successful
      puts '=> Point your browser at http://mtg.throwingbones.com'
    else
      'Something went wrong.'
    end
  end
end

namespace :daemon do
  task :install do
    File.open('daemon.d', 'w') do |f|
      f << File.read('daemon.d.in') % [ $executable_dir, $executable, "-p #{$port}" ]
    end
    sh 'cp -f daemon.d /etc/init.d/mtg'
    sh 'chmod +x /etc/init.d/mtg'
    sh 'rm daemon.d'
  end

  task :at_boot => :install do
    sh 'ln -sf ../init.d/mtg /etc/rc.d/rc2.d/S97mtg'
    sh 'ln -sf ../init.d/mtg /etc/rc.d/rc2.d/K13mtg'
  end
end

