hiera_include('classes')

apt::key { 'icinga':
  id     => 'F51A91A5EE001AA5D77D53C4C6E319C334410682',
  source => 'http://packages.icinga.org/icinga.key', 
}

apt::source { 'icinga':
  location => 'http://packages.icinga.org/ubuntu/',
  release  => 'icinga-trusty-snapshots',
  repos    => 'main',
}

Exec['apt_update'] -> Package <||>

apache::mod { 'rewrite': }

class {'::apache::mod::php': }

mysql::db { 'icinga2_data':
  user     => 'icinga2',
  password => 'icinga2',
}

mysql::db { 'icinga2_web':
  user     => 'icinga2',
  password => 'icinga2',
}

icinga2::object::host { 'blah.com':
  display_name => 'blah.com',
  ipv4_address => '127.0.0.1',
  #groups => ['linux_servers', 'mysql_servers'],
  vars => {
    os              => 'linux',
    virtual_machine => 'true',
    distro          => $::operatingsystem,
  },
  target_dir => '/etc/icinga2/objects/hosts',
  target_file_name => "blah.com.conf"
}

file { '/etc/icingaweb2/modules/monitoring':
  ensure => directory,
  owner  => 'icingaweb2',
  group  => 'icingaweb2',
  mode   => '0775',
}

file { '/etc/icinga2/features-available/ido-mysql.conf':
  ensure  => present,
  content => '/**
 * The db_ido_mysql library implements IDO functionality
 * for MySQL.
 */

library "db_ido_mysql"

object IdoMysqlConnection "ido-mysql" {
  host = "localhost",
  user = "root",
  password = "password",
  database = "icinga2_data"
}
',
}

