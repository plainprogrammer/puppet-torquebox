# Class: torquebox
#
#   This class handles the installation and management of the TorqueBox application server.
#
class torquebox (
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
    }
    default: {
      fail("The torquebox module is not supported on ${::osfamily} based systems")
    }
  }

  class { 'torquebox::java':
    use_latest      => $use_latest,
    openjdk_version => $openjdk_version,
    openjdk_variant => $openjdk_variant
  }


}
