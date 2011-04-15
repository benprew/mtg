file { "/etc/nginx/conf.d/sites.conf":
  source => "puppet:///modules/mtg/sites.conf",
  ensure => file,
}

file { "/etc/init.d/mtg_app":
  source => "puppet:///modules/mtg/mtg_app",
  ensure => file,
}

file { "/etc/sudoers.d/mtg.sudo":
  source => "puppet:///modules/mtg/mtg.sudo",
  mode => 440,
  owner   => root,
  group   => root,
  ensure => file,
}

exec { "update-rc.d mtg_app defaults":
  require => File["/etc/init.d/mtg_app"]
}

# exec { "echo 'includedir /etc/sudoers.d' >> /etc/sudoers": }

package { "nginx": ensure => installed }

service { "nginx":
  ensure    => running,
  require   => Package["nginx"],
  subscribe => File["/etc/nginx/conf.d/sites.conf"],
}



