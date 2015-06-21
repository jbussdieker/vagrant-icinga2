class icinga(
  $db_type     = 'mysql',
  $db_user     = 'root',
  $db_password = 'password',
) {

  Exec['apt_update'] -> Package <||>

  ### CUSTOM APT SETUP ###
  apt::source { 'icinga':
    location   => 'http://packages.icinga.org/ubuntu/',
    release    => 'icinga-trusty-snapshots',
    repos      => 'main',
    key        => {
      id     => 'F51A91A5EE001AA5D77D53C4C6E319C334410682',
      source => 'http://packages.icinga.org/icinga.key',
    },
  }

  ### APACHE CONFIG ###
  class { 'apache':
    mpm_module => 'prefork',
  }

  apache::mod { 'rewrite': }

  class {'::apache::mod::php': }

  ### APT CONFIG ###
  class { 'apt':
    update => {
      frequency => 'daily',
    },
  }

  ### ICINGA 2 CONFIG ###
  class { 'icinga2':
    manage_repos     => false,
    db_type          => $db_type,
    db_user          => $db_user,
    db_pass          => $db_password,
    default_features => [
      'checker',
      'command',
      'mainlog',
      'notification',
      'graphite',
    ],
  }

  ### ICINGA WEB 2 CONFIG ###
  class { 'icingaweb2':
    config_dir_mode     => '0775',
    install_method      => 'package',
    pkg_repo_version    => 'snapshot',
    manage_apache_vhost => true,
    ido_db              => $db_type,
    ido_db_name         => 'icinga2_data',
    ido_db_user         => $db_user,
    ido_db_pass         => $db_password,
    web_db              => $db_type,
    web_db_name         => 'icinga2_web',
    web_db_user         => $db_user,
    web_db_pass         => $db_password,
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
    mode    => '0664',
    owner   => 'icingaweb2',
    group   => 'icingaweb2',
    content => template('icinga/backends.ini'),
  }

  file { '/etc/icingaweb2/modules/monitoring/instances.ini':
    ensure  => present,
    mode    => '0664',
    owner   => 'icingaweb2',
    group   => 'icingaweb2',
    content => template('icinga/instances.ini'),
  }

  file { '/etc/icingaweb2/enabledModules/monitoring':
    ensure  => link,
    target  => '/usr/share/icingaweb2/modules/monitoring',
    require => Package['icingaweb2'],
  }

  ### MYSQL SPECIFIC ###
  if $db_type == 'mysql' {

    class { 'mysql::server':
      root_password           => 'password',
      remove_default_accounts => true,
    }

    class { 'icinga2::feature::ido_mysql': }

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
      notify   => Exec['create_web_user'],
    }

    $default_user = 'icingaadmin'
    $default_password = '\$1\$usghGMNC\$h8Lk.QA8OUSvEkz45o.0u1'

    exec { 'create_web_user':
      command     => "/usr/bin/mysql -u ${db_user} -p${db_password} icinga2_web -e \"insert into icingaweb_user VALUES ('${default_user}', 1, '${default_password}', NULL, NULL);\"",
      refreshonly => true,
    }

  }

}
