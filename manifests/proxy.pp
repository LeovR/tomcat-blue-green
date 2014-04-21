class proxy {
  include apt

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
  }

  # install necessary ubuntu packages to setup the environment
  package { ["vim",
             "curl",
             "git-core",
			       "expect",
             "bash",
             "haproxy"]:
    ensure => present,
    require => Exec["apt-get update"],
  }

  group { "puppet":
    ensure  => present,
  }

  package { "acpid":
    ensure  => installed,
  }

  package { "wget":
    ensure  => installed,
  }

  file { "/etc/default/haproxy":
    ensure    => present,
    content   => "ENABLED=1",
    require => Package["haproxy"]
  }

  file { "/etc/haproxy/haproxy.cfg":
    ensure => present,
    source => "puppet:///modules/haproxy/haproxy.cfg",
    require => Package["haproxy"],
    notify => Service["haproxy"]
  }

  service { "rsyslog":
    enable => true,
    ensure => running
  }

  service { "haproxy":
    enable => true,
    ensure => running,
    require => Package["haproxy"]
  }

  file {"/etc/rsyslog.d/49-haproxy.conf":
    ensure => present,
    source => "puppet:///modules/haproxy/haproxy-logging.conf",
    notify => Service["rsyslog"]
  }

  
}

include proxy
