file { "/etc/nginx/conf.d/sites.conf":
  source => "puppet:///modules/mtg/sites.conf",
  ensure => file,
}

file { "/var/www/mtg/shared/config/database.yml":
  source => "puppet:///modules/mtg/database.yml",
  owner => 'throwingbones',
  ensure => file,
}

package { "nginx": ensure => installed }

service { "nginx":
  ensure    => running,
  require   => Package["nginx"],
  subscribe => File["/etc/nginx/conf.d/sites.conf"],
}



