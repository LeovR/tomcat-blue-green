class java-development-env {
  include apt
  include maven

  apt::ppa { "ppa:webupd8team/java": }

  # Set current Tomcat download url.
  $tomcat_url = "http://mirror.netcologne.de/apache.org/tomcat/tomcat-7/v7.0.53/bin/apache-tomcat-7.0.53.tar.gz"

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  exec { 'apt-get update 2':
    command => '/usr/bin/apt-get update',
    require => [ Apt::Ppa["ppa:webupd8team/java"], Package["git-core"] ],
  }

  # install necessary ubuntu packages to setup the environment
  package { ["vim",
             "curl",
             "git-core",
			       "expect",
             "bash"]:
    ensure => present,
    require => Exec["apt-get update"],
    before => Apt::Ppa["ppa:webupd8team/java"],
  }

  package { ["oracle-java7-installer"]:
    ensure => present,
    require => Exec["apt-get update 2"],
  }

  exec {
    "accept_license":
    command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
    cwd => "/home/vagrant",
    user => "vagrant",
    path    => "/usr/bin/:/bin/",
    require => Package["curl"],
    before => Package["oracle-java7-installer"],
    logoutput => true,
  }

  maven::settings { 'mvn-settings' :
		local_repo          => '/vagrant/maven/.m2/repository'
  }

  Exec {
    path  => "${::path}",
  }

  group { "puppet":
    ensure  => present,
  }

  package { "acpid":
    ensure  => installed,
  }

  package { "supervisor":
    ensure  => installed,
  }
  package { "wget":
    ensure  => installed,
  }

  user { "vagrant":
    ensure    => present,
    comment   => "Tomcat User",
    home      => "/home/vagrant",
    shell     => "/bin/bash",
  }

  exec { "check_tomcat_url":
    cwd       => "/tmp",
    command   => "wget -S --spider ${tomcat_url}",
    timeout   => 900,
    require   => Package["wget"],
    notify    => Exec["get_tomcat"],
    logoutput => "on_failure"
  }

  exec { "get_tomcat":
    cwd       => "/tmp",
    command   => "wget ${tomcat_url} -O tomcat.tar.gz > /opt/.tomcat_get_tomcat",
    creates   => "/opt/.tomcat_get_tomcat",
    timeout   => 900,
    require   => Package["wget"],
    notify    => Exec["extract_tomcat"],
    logoutput => "on_failure"
  }
  exec { "extract_tomcat":
    cwd         => "/tmp",
    command     => "tar zxf /tmp/tomcat.tar.gz ; mv apache* /srv/tomcat",
    creates     => "/srv/tomcat",
    require     => Exec["get_tomcat"],
    refreshonly => true,
  }
	file { "/srv/tomcat/conf/tomcat-users.xml":
		ensure    => present,
		content   => "<?xml version='1.0' encoding='utf-8'?>
	<tomcat-users>
	  <user username=\"admin\" password=\"tomcat\" roles=\"manager-gui\"/>
	</tomcat-users>",
		require   => Exec["extract_tomcat"],
	  }

  file { "/srv/tomcat":
    ensure    => directory,
    owner     => "vagrant",
    mode      => 0755,
    recurse   => true,
    require   => Exec["extract_tomcat"],
  }
  file { "/etc/supervisor/conf.d/tomcat.conf":
    ensure    => present,
    content   => "[program:tomcat]
command=/srv/tomcat/bin/catalina.sh run
directory=/srv/tomcat/bin
autostart=yes
user=vagrant
stopsignal=QUIT",
    require   => [ Package["supervisor"], File["/srv/tomcat/conf/tomcat-users.xml"] ],
    notify    => Exec["update_supervisor"],
  }
  exec { "update_supervisor":
    command     => "supervisorctl update",
    refreshonly => true,
  }

  
}

include java-development-env
