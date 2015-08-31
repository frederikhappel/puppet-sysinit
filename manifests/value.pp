# manage an sysinit entry
define sysinit::value (
  $process,
  $inittabid = undef,
  $runlevels = "2345",
  $action = "respawn",
  $ensure = present
) {
  # validate parameters
  validate_string($inittabid, $process, $runlevels, $action)
  validate_re($ensure, '^(present|absent)$')

  # dependency on baseclass
  require ::sysinit

  # select provider to use
  case $::operatingsystemmajrelease {
    5 : {
      # centos 5 uses inittab
      sysinit::inittab::value {
        $name :
          ensure => $ensure,
          id => $inittabid ? { undef => truncate(md5($name),2), default => $inittabid },
          process => $process,
          runlevels => $runlevels,
          action => $action ;
      }
    }

    default : {
      # default use upstart
      sysinit::upstart::value {
        $name :
          ensure => $ensure,
          process => $process,
          starton => "stopped rc RUNLEVEL=[${runlevels}]",
          stopon => 'starting runlevel [!$RUNLEVEL]',
          action => $action ;
      }
    }
  }
}
