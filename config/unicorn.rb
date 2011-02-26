# unicorn -c config/unicorn.rb -E production -D
# set path to app that will be used to configure unicorn, 
# note the trailing slash in this example

worker_processes 2

preload_app true

timeout 30

# Specify path to socket unicorn listens to, 
# we will use this in our nginx.conf later
listen "127.0.0.1:10000", :backlog => 2048

# Set process id path
pid "tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log" 
