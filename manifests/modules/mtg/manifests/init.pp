file { "/etc/nginx/conf.d/sites.conf":
  source => "puppet:///modules/mtg/sites.conf",
  ensure => file,
}

package { "nginx": ensure => installed }

service { "nginx":
  ensure    => running,
  require   => Package["nginx"],
  subscribe => File["/etc/nginx/conf.d/sites.conf"],
}



