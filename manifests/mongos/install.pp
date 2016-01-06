# PRIVATE CLASS: do not call directly
class xhmongo::mongos::install (
  $package_ensure           = $xhmongo::mongos::package_ensure,
  $package_name             = $xhmongo::mongos::package_name,
) {

  case $package_ensure {
    true:     {
      $my_package_ensure = 'present'
    }
    false:    {
      $my_package_ensure = 'absent'
    }
    'absent': {
      $my_package_ensure = 'absent'
    }
    'purged': {
      $my_package_ensure = 'purged'
    }
    default:  {
      $my_package_ensure = $package_ensure
    }
  }

  if !defined(Package[$package_name]) {
    package { 'mongodb_mongos':
      ensure => $my_package_ensure,
      name   => $package_name,
    }
  }

}
