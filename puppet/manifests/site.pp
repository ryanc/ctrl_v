include '::ntp'

Package {
  require => Exec['apt-get update'],
}

exec { 'apt-get update':
  command => '/usr/bin/apt-get update',
}

apt::ppa { 'ppa:brightbox/ruby-ng': }

$ruby_packages = [ 'ruby2.1', 'ruby2.1-dev', 'ruby-switch' ]

package { $ruby_packages:
  require => Apt::Ppa['ppa:brightbox/ruby-ng'],
  ensure  => latest,
}

exec { 'bundler':
  command => '/usr/bin/gem install bundler',
  require => Exec['ruby-switch'],
  unless => '/usr/bin/test -e /usr/local/bin/bundle',
}

exec { 'ruby-switch':
  command => '/usr/bin/ruby-switch --set ruby2.1',
  require => Package['ruby-switch'],
}

class { 'nginx':
  manage_repo => false,
}

class { 'postgresql::server': }

postgresql::server::db { 'ctrl_v':
  user     => 'ctrl_v',
  password => postgresql_password('ctrl_v', 'password'),
}

class { 'postgresql::lib::devel': }

file { ['/srv/apps', '/srv/apps/ctrl_v']:
  ensure  => directory,
  owner   => 'vagrant',
}

package { 'git':
  ensure => latest,
}

nginx::resource::vhost { 'default':
  www_root         => '/srv/apps/ctrl_v/current/public',
  server_name      => ['_'],
  try_files        => ['$uri/index.html', '$uri.html', '$uri', '@app'],
  index_files      => ['index.html'],
  proxy_set_header => ['Host $http_host', 'X-Forwarded-Proto $scheme', 'X-Forwarded-For $proxy_add_x_forwarded_for'],
}

nginx::resource::upstream { 'app_server':
  members => [ 'localhost:8080' ],
}

nginx::resource::location { '@app':
  vhost            => 'default',
  proxy            => 'http://app_server',
}
