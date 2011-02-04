set :stages, %w(staging production)
set :default_stage, "production"
require 'capistrano/ext/multistage'

set :application, "mtg"
set :user, 'throwingbones'

set :deploy_to, "/var/www/mtg"

set :scm, :git
set :scm_command, '/usr/bin/git'
set :local_scm_command, `which git`.chomp
set :repository, 'git://github.com/benprew/mtg.git'
set :branch, 'master'
set :deploy_via, :remote_cache

set :app_port, 10000
set :app_name, 'mtg.rb'
set :web, "apache"
set :use_sudo, false

set :shared_files, [ 'public/sets', 'config/database.yml' ]

default_environment["PATH"] =
  "/bin:/usr/bin:/usr/local/ruby/bin/:/usr/local/bin:/usr/sbin:/var/lib/gems/1.8/bin/"

