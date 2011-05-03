load 'deploy' if respond_to?(:namespace) # cap2 differentiator

require 'rubygems'
require 'railsless-deploy'
require 'bundler/capistrano'
load    'config/deploy'

after 'deploy:update', :link_shared_files

task :link_shared_files do

  command = shared_files.map do |file|
    "rm -f #{release_path}/#{file} && \
    ln -s #{shared_path}/#{file} #{release_path}/#{file}"
  end.join " && "
  run command
end

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

namespace :deploy do
  desc "Deploy the MFer"
  task :default do
    update
    restart
  end

  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    dirs = [ deploy_to, shared_path, "#{shared_path}/tmp/pids", "#{shared_path}/tmp/sockets", "#{shared_path}/log" ]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    sudo "/etc/init.d/#{application}_app restart"
  end

  task :start, :roles => :app, :except => { :no_release => true } do
    sudo "/etc/init.d/#{application}_app start"
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end

