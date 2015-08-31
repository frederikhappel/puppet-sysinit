# manage an upstart entry
define sysinit::upstart::value (
  $process,
  $starton,
  $stopon,
  $action = "respawn",
  $ensure = present
) {
  # validate parameters
  validate_string($process, $starton, $stopon, $action)
  validate_re($ensure, '^(present|absent)$')

  # define variables
  $cfgfile = "${sysinit::upstart::params::cfgddir}/${name}.conf"

  case $ensure {
    present : {
      # create upstart configuration
      file {
        $cfgfile :
          content => template("sysinit/upstart.conf.erb"),
          mode => "0644" ;
      }

      # reload upstart configuration
      exec {
        "sysinitUpstartReload_${name}" :
          command => "/sbin/restart ${name} || /sbin/start ${name}",
          onlyif => "test -f ${cfgfile}",
          subscribe => File[$cfgfile],
          refreshonly => true ;
      }
    }

    absent : {
      # reload upstart configuration
      exec {
        "sysinitUpstartReload_${name}" :
          command => "/sbin/stop ${name} || true",
          onlyif => "test -f ${cfgfile}",
          before => File[$cfgfile],
      }

      # remove upstart configuration
      file {
        $cfgfile :
          ensure => absent,
          force => true ;
      }
    }
  }
}
