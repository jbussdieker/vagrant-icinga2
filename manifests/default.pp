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
apache::mod { 'php5': }
