# inittab module
class sysinit::inittab::setup inherits sysinit::inittab::params {
  # package management
  package {
    "initscripts" :
      ensure => present ;
  }

  # ensure inittab is present
  file {
    $cfgfile :
      ensure => present,
      mode => "0644",
      require => Package["initscripts"] ;
  }

  # reload inittab
  exec {
    "sysinitInittabReload" :
      command => "/sbin/telinit q",
      require => File[$cfgfile],
      refreshonly => true ;
  }
}
