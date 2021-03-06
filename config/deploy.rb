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
set :branch, 'origin/master'

set :use_sudo, false

set :shared_files, [ 'public/sets', 'config/database.yml', 'log', 'tmp',  'public/google70ae3d6b04281c2c.html' ]

default_environment["PATH"] =
  "/bin:/usr/bin:/usr/local/ruby/bin/:/usr/local/bin:/usr/sbin:/var/lib/gems/1.8/bin/"
