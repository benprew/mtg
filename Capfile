load 'deploy' if respond_to?(:namespace) # cap2 differentiator

require 'rubygems'
require 'railsless-deploy'
require 'bundler/capistrano'
load    'config/deploy'

after 'deploy:update', :daemonize
after 'deploy:update', :link_shared_files

after 'deploy', 'deploy:cleanup'
after 'deploy', 'deploy:restart'

namespace :deploy do
  spinner = "bin/spinner_for_#{app_name}"

  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path} && bundle exec #{spinner} start"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path} && bundle exec #{spinner} stop"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path} && bundle exec #{spinner} restart"
  end

end

task :daemonize do
  spinner = "#{release_path}/bin/spinner_for_#{app_name}"
  run "#{release_path}/bin/create_spinner.rb '#{deploy_to}/current' '#{app_name}' '#{app_port}' >#{spinner}"
  run "chmod +x #{spinner}"
  run "ln -sf #{spinner} /etc/init.d/#{app_name}"
  run "update-rc.d #{app_name} defaults || echo 'Already in rc.d'"
end

task :link_shared_files do
  shared_files.each do |file|
    run "ln -s #{shared_path}/#{file} #{release_path}/#{file}"
  end
end

