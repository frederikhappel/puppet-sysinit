# manage an inittab entry
define sysinit::inittab::value (
  $id,
  $process,
  $runlevels,
  $action,
  $ensure = present
) {
  # validate parameters
  validate_string($id, $process, $runlevels, $action)
  validate_re($ensure, '^(present|absent)$')

  # defaults
  Augeas {
    incl => $sysinit::inittab::params::cfgfile,
    lens => "Inittab.lns",
    load_path => "/usr/share/augeas/lenses/dist",
    notify => Exec["sysinitInittabReload"],
  }

  case $ensure {
    present : {
      # actually create an entry
      augeas {
        "sysinitInittabValue_${id}" :
          changes => [
            "set ${id}/runlevels ${runlevels}",
            "set ${id}/action ${action}",
            "set ${id}/process \"${process}\"",
          ] ;
      }
    }

    absent : {
      # actually remove an entry
      augeas {
        "sysinitInittabValue_${id}" :
          changes => [
            "remove ${id}",
          ],
          onlyif => "match ${id} size > 0" ;
      }
    }
  }
}
