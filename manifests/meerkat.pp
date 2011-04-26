import "mysql"
import "mtg"
import "postgres"

Exec { path => "/usr/bin:/bin:/usr/sbin" }

package { "git-core": ensure => installed }
package { "mysql-server": ensure => installed, require => Package["mysql-client"] }
package { "mysql-client": ensure => installed, require => Exec["apt-update"] }
package { "vim": ensure => installed }
package { "libshadow-ruby1.8": ensure => installed }
package { "libmysqlclient-dev": ensure => installed }
package { "libsqlite3-dev": ensure => installed }
package { "libxml2-dev": ensure => installed }
package { "libxslt1-dev": ensure => installed }
package { "postgresql-8.4": ensure => installed, require => Exec["apt-update"] }
package { "rake": ensure => installed }

postgres::database { "mtg":
  ensure => present,
  name => 'mtg',
  require => Package['postgresql-8.4'],
}

postgres::role { "mtg":
  password => "*6F6FAA28F5A830A76C08AA0EDB4E4DF5B0A36C35",
  ensure => present,
}

exec { "apt-update":
        command     => "/usr/bin/apt-get update",
        refreshonly => true;
}

exec { "gem install bundler": }

user { "throwingbones":
  home     => '/home/throwingbones',
  password => '$1$nM37mz9i$AOdQ9hkhY2bKDYIo/cbDn0',
  shell    => '/bin/bash',
  groups   => 'users',
  require  => Package['libshadow-ruby1.8'],
  ensure   => present,
}

file { "/etc/init.d":
  ensure => directory,
  mode => 777,
}

file { "/var/run":
  ensure => directory,
  mode   => 775,
  group  => 'users',
}

file { "/var/log":
  ensure => directory,
  mode   => 775,
  group  => 'users',
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
  ensure => present,
  require => Package["mysql-server"],
}

mysql_database { "mtg":
  defaults => "/etc/mysql/debian.cnf",
  name => 'mtg',
  ensure => present,
  require => Package["mysql-server"],
}

mysql_grant { "mtg@localhost/mtg":
  defaults => "/etc/mysql/debian.cnf",
  privileges => 'all',
  require => Package["mysql-server"],
}
