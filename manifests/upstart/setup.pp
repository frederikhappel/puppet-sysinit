# inittab module
class sysinit::upstart::setup inherits sysinit::upstart::params {
  # package management
  package {
    "upstart" :
      ensure => present ;
  }

  # ensure inittab is present
  file {
    $cfgddir :
      ensure => directory,
      mode => "0755",
      require => Package["upstart"] ;
  }
}
