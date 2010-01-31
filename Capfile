load 'deploy' if respond_to?(:namespace) # cap2 differentiator

require 'rubygems'
require 'railsless-deploy'
load    'config/deploy'

after 'deploy:update', :daemonize
after 'deploy:update', :link_shared_files

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/#{app_name} start"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/#{app_name} stop"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/#{app_name} restart"
  end

end

task :daemonize do
  run "#{release_path}/bin/create_spinner.rb #{app_name} #{app_port} >/tmp/spin"
  run "cp /tmp/spin /etc/init.d/#{app_name} && rm /tmp/spin"
  run "chmod +x /etc/init.d/#{app_name}"
  run "ln -sf ../init.d/mtg /etc/rc.d/rc2.d/S97#{app_name}"
  run "ln -sf ../init.d/mtg /etc/rc.d/rc2.d/K13#{app_name}"
end

task :link_shared_files do
  run "ln -s #{shared_path}/sets #{release_path}/public/sets"
end

