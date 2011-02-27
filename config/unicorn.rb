# unicorn -c config/unicorn.rb -E production -D
# set path to app that will be used to configure unicorn, 
# note the trailing slash in this example

@app_root = "/var/www/mtg/current/"

worker_processes 2
working_directory @app_root

preload_app true

timeout 30

# Specify path to socket unicorn listens to, 
# we will use this in our nginx.conf later
listen "0.0.0.0:10000", :backlog => 2048

# Set process id path
pid "tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = @app_root + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

