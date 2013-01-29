# Class: torquebox::java
#
#   This class provides for the installation of the required OpenJDK components needed by TorqueBox
#
class torquebox::java (
  $use_latest       = false,
  $openjdk_version  = 6,
  $openjdk_variant  = 'headless'
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

      if $openjdk_variant == undef {
        $package_name = "openjdk-${openjdk_version}-jre"
      } elsif $openjdk_variant == '' {
        $package_name = "openjdk-${openjdk_version}-jre"
      } else {
        $package_name = "openjdk-${openjdk_version}-jre-${openjdk_variant}"
      }

      exec {'update_package_sources':
        command => '/usr/bin/apt-get update -qq',
        before  => Package[$package_name]
      }
    }
    default: {
      fail("The torquebox::java module is not supported on ${::osfamily} based systems")
    }
  }

  package { $package_name:
    ensure => $package_ensure
  }
}
