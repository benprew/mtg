#!/usr/local/bin/ruby

require 'fileutils'

include FileUtils

(app_dir, app_name, app_port) = ARGV

puts %q{#!/usr/local/bin/ruby

require 'rubygems'
require 'daemons'

pwd = "%s"
executable = "%s"
extra_options = "%s"
Daemons.run_proc(executable, :log_output => 1, :dir_mode => :system) do
  Dir.chdir(pwd)
  exec "/usr/local/ruby/bin/ruby #{executable} -e production #{extra_options}"
end
} % [ app_dir, app_name, "-p #{app_port}" ]
