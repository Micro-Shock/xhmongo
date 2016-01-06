# PRIVATE CLASS: do not call directly
class xhmongo::client::install {
  $package_ensure = $xhmongo::client::ensure
  $package_name   = $xhmongo::client::package_name

  case $package_ensure {
    true:     {
      $my_package_ensure = 'present'
    }
    false:    {
      $my_package_ensure = 'purged'
    }
    'absent': {
      $my_package_ensure = 'purged'
    }
    default:  {
      $my_package_ensure = $package_ensure
    }
  }

  if $package_name {
    package { 'mongodb_client':
      ensure => $my_package_ensure,
      name   => $package_name,
      tag    => 'mongodb',
    }
  }
}
