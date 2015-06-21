class icinga {

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

  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'icinga2',
    sql      => '/usr/share/icinga2-ido-mysql/schema/mysql.sql',
    require  => Package['icinga2'],
  }

  mysql::db { 'icinga2_web':
    user     => 'icinga2',
    password => 'icinga2',
    sql      => '/usr/share/icingaweb2/etc/schema/mysql.schema.sql',
    require  => Package['icingaweb2'],
  }

  class { 'apache':
    mpm_module => 'prefork',
  }

  class {'::apache::mod::php': }

  class { 'apt':
    update => {
      frequency => 'daily',
    },
  }

  class { 'icinga2':
    manage_repos     => false,
    db_user          => 'root',
    db_pass          => 'password',
    default_features => [
      'checker',
      'command',
      'mainlog',
      'notification',
      'graphite',
    ],
  }

  class { 'icinga2::feature::ido_mysql': }

  class { 'icingaweb2':
    config_dir_mode     => '0775',
    install_method      => 'package',
    pkg_repo_version    => 'snapshot',
    manage_apache_vhost => true,
    ido_db_name         => 'icinga2_data',
    ido_db_user         => 'root',
    ido_db_pass         => 'password',
    web_db_name         => 'icinga2_web',
    web_db_user         => 'root',
    web_db_pass         => 'password',
  }

  class { 'mysql::server':
    root_password           => 'password',
    remove_default_accounts => true,
  }

  file { '/etc/icingaweb2/modules/monitoring':
    ensure  => directory,
    mode    => '0775',
    owner   => 'icingaweb2',
    group   => 'icingaweb2',
    require => Package['icingaweb2'],
  }

  file { '/etc/icingaweb2/modules/monitoring/backends.ini':
    ensure  => present,
    owner   => 'icingaweb2',
    group   => 'icingaweb2',
    content => template('icinga/backends.ini'),
  }

  file { '/etc/icingaweb2/modules/monitoring/instances.ini':
    ensure  => present,
    owner   => 'icingaweb2',
    group   => 'icingaweb2',
    content => template('icinga/instances.ini'),
  }

  file { '/etc/icingaweb2/enabledModules/monitoring':
    ensure  => link,
    target  => '/usr/share/icingaweb2/modules/monitoring',
    require => Package['icingaweb2'],
  }

}
