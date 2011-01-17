import "mysql"
import "mtg"

Exec { path => "/usr/bin:/bin" }

package { "git": ensure => installed }
package { "vim": ensure => installed }
package { "libshadow-ruby1.8": ensure => installed }
package { "libmysqlclient-dev": ensure => installed }
package { "libsqlite3-dev": ensure => installed }

exec { "gem install bundler": }

user { "throwingbones":
  home     => '/home/throwingbones',
  password => '$1$nM37mz9i$AOdQ9hkhY2bKDYIo/cbDn0',
  shell    => '/bin/bash',
  ensure   => present,
}

file { "/etc/init.d":
  ensure => directory,
  mode => 777,
}

file { "/var/run":
  ensure => directory,
  mode   => 775,
  group  => 'throwingbones',
}

file { "/var/log":
  ensure => directory,
  mode   => 775,
  group  => 'throwingbones',
}

file { "/home/throwingbones":
  ensure  => directory,
  owner   => 'throwingbones',
  group   => 'users',
  require => User["throwingbones"],
}

file { "/var/www/mtg":
  ensure  => directory,
  owner   => 'throwingbones',
  group   => 'users',
  require => User["throwingbones"],
}


# databases

mysql_user { "mtg":
  defaults => "/etc/mysql/debian.cnf",
  name => 'mtg',
  password_hash => "*6F6FAA28F5A830A76C08AA0EDB4E4DF5B0A36C35",
  ensure => present
}

mysql_database { "mtg":
  defaults => "/etc/mysql/debian.cnf",
  name => 'mtg',
  ensure => present
}

mysql_grant { "mtg@localhost/mtg":
  defaults => "/etc/mysql/debian.cnf",
  privileges => 'all',
}

mysql_database { "mtgtest":
  defaults => "/etc/mysql/debian.cnf",
  name => 'mtgtest',
  ensure => present
}

mysql_grant { "mtg@localhost/mtgtest":
  defaults => "/etc/mysql/debian.cnf",
  privileges => 'all',
}
