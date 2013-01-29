# Class: torquebox
#
#   This class handles the installation and management of the TorqueBox application server.
#
class torquebox (
  $use_latest       = false,
  $openjdk_version  = 6,
  $openjdk_variant  = 'headless',

  $version          = '2.3.0',
  $add_to_path      = false
) {
  if $use_latest == true {
    $package_ensure = latest
  } elsif $use_latest == false {
    $package_ensure = present
  } else {
    fail('The use_latest parameter must be either true or false.')
  }

  case $::osfamily {
    Debian: {
      $supported = true
    }
    default: {
      fail("The torquebox module is not supported on ${::osfamily} based systems")
    }
  }

  $torquebox_package = "torquebox-dist-${version}-bin.zip"
  $torquebox_source = "http://repository-projectodd.forge.cloudbees.com/release/org/torquebox/torquebox-dist/${version}/${torquebox_package}"

  class { 'torquebox::java':
    use_latest      => $use_latest,
    openjdk_version => $openjdk_version,
    openjdk_variant => $openjdk_variant
  }

  package { 'unzip':
    ensure => $package_ensure
  }

  file { ['/root/src', '/opt/torquebox']:
    ensure => directory
  }

  group { 'torquebox':
    ensure => present
  }

  user { 'torquebox':
    ensure  => present,
    gid     => 'torquebox',
    home    => '/opt/torquebox',
    require => Group['torquebox']
  }

  exec { 'install_torquebox':
    cwd       => '/root/src',
    command   => "/usr/bin/wget ${torquebox_source} &&
                  /usr/bin/unzip ${torquebox_package} &&
                  /bin/mv torquebox-${version} /opt/torquebox/${version} &&
                  /bin/ln -s /opt/torquebox/${version} /opt/torquebox/current &&
                  /bin/chown -R torquebox:torquebox /opt/torquebox",
    creates   => '/opt/torquebox/current/jboss/bin/standalone.sh',
    logoutput => on_failure,
    timeout   => 0,
    require   => [Package['unzip'], File['/root/src','/opt/torquebox'], User['torquebox']]
  }

  file { '/etc/profile.d/torquebox_vars.sh':
    ensure  => present,
    source  => 'puppet:///modules/torquebox/torquebox_vars.sh',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Exec['install_torquebox'],
    before  => [ Exec['install_upstart'], Service['torquebox'] ]
  }

  if $add_to_path == true {
    file { '/etc/profile.d/torquebox_path.sh':
      ensure  => present,
      source  => 'puppet:///modules/torquebox/torquebox_path.sh',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File['/etc/profile.d/torquebox_vars.sh']
    }
  }

  exec { 'install_upstart':
    command   => '/bin/cp /opt/torquebox/current/share/init/torquebox.conf /etc/init/torquebox.conf',
    creates   => '/etc/init/torquebox.conf',
    require   => Exec['install_torquebox']
  }

  service { 'torquebox':
    ensure  => running,
    enable  => true,
    require => Exec['install_upstart']
  }
}
