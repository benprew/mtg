# mysql.pp
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class mysql::server {

	package { "mysql-server":
		ensure => installed,
	}

	service { mysql:
		ensure => running,
		hasstatus => true,
		require => Package["mysql-server"],
	}

}
