# manage an sysinit entry
define sysinit::chkconfig (
  $runlevels = '-',
  $start = undef,
  $stop = undef,
  $ensure = present
) {
  # validate parameters
  if $ensure == present {
    validate_string($runlevels)
    validate_integer($start, 99, 0)
    validate_integer($stop, 99, 0)
  }
  validate_re($ensure, '^present$|^absent$|^delete$')

  # dependency on baseclass
  require ::sysinit

  # define variables
  $cfgfile = "${sysinit::params::cfgddir}/${name}"

  # manage file
  file {
    $cfgfile :
      ensure => $ensure ? { delete => absent, default => $ensure },
      content => "# chkconfig: ${runlevels} ${start} ${stop}\n",
  }

  case $ensure {
    delete : {
      # remove service
      exec {
        "sysinitChkconfig_delete_${name}" :
          command => "chkconfig --del ${name}",
          onlyif => "chkconfig --list ${name}"
      }
    }

    default : {
      # reconfigure chkconfig for service
      exec {
        "sysinitChkconfig_reconfigure_${name}" :
          command => "chkconfig --del ${name} ; chkconfig --add ${name}",
          refreshonly => true,
          subscribe => File[$cfgfile] ;
      }
    }
  }
}
