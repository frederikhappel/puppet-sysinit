# sysinit module handling different init mechanisms
class sysinit inherits sysinit::params {
  # package management
  package {
    'chkconfig' :
      ensure => installed ;
  }
  file {
    $cfgddir :
      ensure => directory,
      owner => 0,
      group => 0 ;
  }

  # select provider to use
  case $::operatingsystemmajrelease {
    5 : {
      # centos 5 uses inittab
      include sysinit::inittab::setup
    }

    6 : {
      # default use upstart
      include sysinit::upstart::setup
    }

    default : {
      fail("unsupported release version! please fix in module sysinit!")
    }
  }
}
