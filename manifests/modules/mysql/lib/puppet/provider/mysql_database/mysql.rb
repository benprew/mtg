require 'puppet/provider/package'

Puppet::Type.type(:mysql_database).provide(:mysql,
		:parent => Puppet::Provider::Package) do

	desc "Use mysql as database."
	commands :mysqladmin => '/usr/bin/mysqladmin'
	commands :mysql => '/usr/bin/mysql'

        # retrieve the current set of mysql users
	def self.instances
		dbs = []

		cmd = "#{command(:mysql)} mysql -NBe 'show databases'"
		execpipe(cmd) do |process|
			process.each do |line|
				dbs << new( { :ensure => :present, :name => line.chomp } )
			end
		end
		return dbs
	end

	def munge_args(*args)
		@resource[:defaults] ||= ""
		if @resource[:defaults] != "" 
			[ "--defaults-file="+@resource[:defaults] ] + args
		else
			args
		end
	end

	def query
		result = {
			:name => @resource[:name],
			:ensure => :absent
		}

		cmd = ( [ command(:mysql) ] + munge_args("mysql", "-NBe", "'show databases'") ).join(" ")
		execpipe(cmd) do |process|
			process.each do |line|
				if line.chomp.eql?(@resource[:name])
					result[:ensure] = :present
				end
			end
		end
		result
	end

	def create
		mysqladmin munge_args("create", @resource[:name])
	end

	def destroy
		mysqladmin munge_args("-f", "drop", @resource[:name])
	end

	def exists?
		mysql(munge_args("mysql", "-NBe", "show databases")).match(/^#{@resource[:name]}$/)
	end
end

