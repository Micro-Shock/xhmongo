# PRIVATE CLASS: do not use directly
class xhmongo::params inherits xhmongo::globals {
  $ensure                = true
  $mongos_ensure         = true
  $ipv6                  = undef
  $service_manage        = pick($xhmongo::globals::mongod_service_manage, true)
  $service_enable        = pick($xhmongo::globals::service_enable, true)
  $service_ensure        = pick($xhmongo::globals::service_ensure, 'running')
  $service_status        = $xhmongo::globals::service_status
  $restart               = true
  $create_admin          = false
  $admin_username        = 'admin'
  $store_creds           = false
  $rcfile                = "${::root_home}/.mongorc.js"

  $mongos_service_manage = pick($xhmongo::globals::mongos_service_manage, true)
  $mongos_service_enable = pick($xhmongo::globals::mongos_service_enable, true)
  $mongos_service_ensure = pick($xhmongo::globals::mongos_service_ensure, 'running')
  $mongos_service_status = $xhmongo::globals::mongos_service_status
  $mongos_configdb       = '127.0.0.1:27019'
  $mongos_restart        = true

  $manage_package        = pick($xhmongo::globals::manage_package, $xhmongo::globals::manage_package_repo, false)

  # Amazon Linux's OS Family is 'Linux', operating system 'Amazon'.
  case $::osfamily {
    'RedHat', 'Linux': {

      if $manage_package {
        $user        = pick($::xhmongo::globals::user, 'mongod')
        $group       = pick($::xhmongo::globals::group, 'mongod')
        if ($::xhmongo::globals::version == undef) {
          $server_package_name   = pick($::xhmongo::globals::server_package_name, 'mongodb-org-server')
          $client_package_name   = pick($::xhmongo::globals::client_package_name, 'mongodb-org-shell')
          $mongos_package_name   = pick($::xhmongo::globals::mongos_package_name, 'mongodb-org-mongos')
          $package_ensure        = true
          $package_ensure_client = true
          $package_ensure_mongos = true
        } else {
          # check if the version is greater than 2.6
          if(versioncmp($::xhmongo::globals::version, '2.6.0') >= 0) {
            $server_package_name   = pick($::xhmongo::globals::server_package_name, 'mongodb-org-server')
            $client_package_name   = pick($::xhmongo::globals::client_package_name, 'mongodb-org-shell')
            $mongos_package_name   = pick($::xhmongo::globals::mongos_package_name, 'mongodb-org-mongos')
            $package_ensure        = $::xhmongo::globals::version
            $package_ensure_client = $::xhmongo::globals::version
            $package_ensure_mongos = $::xhmongo::globals::version
          } else {
            $server_package_name   = pick($::xhmongo::globals::server_package_name, 'mongodb-10gen')
            $client_package_name   = pick($::xhmongo::globals::client_package_name, 'mongodb-10gen')
            $mongos_package_name   = pick($::xhmongo::globals::mongos_package_name, 'mongodb-10gen')
            $package_ensure        = $::xhmongo::globals::version
            $package_ensure_client = $::xhmongo::globals::version #this is still needed in case they are only installing the client
            $package_ensure_mongos = $::xhmongo::globals::version
          }
        }
        $service_name            = pick($::xhmongo::globals::service_name, 'mongod')
        $mongos_service_name     = pick($::xhmongo::globals::mongos_service_name, 'mongos')
        $config                  = '/etc/mongod.conf'
        $mongos_config           = '/etc/mongodb-shard.conf'
        $dbpath                  = '/var/lib/mongodb'
        $logpath                 = '/var/log/mongodb/mongod.log'
        $pidfilepath             = '/var/run/mongodb/mongod.pid'
        $bind_ip                 = pick($::xhmongo::globals::bind_ip, ['127.0.0.1'])
        $fork                    = true
        $mongos_pidfilepath      = undef
        $mongos_unixsocketprefix = undef
        $mongos_logpath          = undef
        $mongos_fork             = undef
      } else {
        # RedHat/CentOS doesn't come with a prepacked mongodb
        # so we assume that you are using EPEL repository.
        if ($::xhmongo::globals::version == undef) {
          $package_ensure = true
          $package_ensure_client = true
          $package_ensure_mongos = true
        } else {
          $package_ensure = $::xhmongo::globals::version
          $package_ensure_client = $::xhmongo::globals::version
          $package_ensure_mongos = $::xhmongo::globals::version
        }
        $user                = pick($::xhmongo::globals::user, 'mongodb')
        $group               = pick($::xhmongo::globals::group, 'mongodb')
        $server_package_name = pick($::xhmongo::globals::server_package_name, 'mongodb-server')
        $client_package_name = pick($::xhmongo::globals::client_package_name, 'mongodb')
        $mongos_package_name = pick($::xhmongo::globals::mongos_package_name, 'mongodb-server')
        $service_name        = pick($::xhmongo::globals::service_name, 'mongod')
        $dbpath              = '/var/lib/mongodb'
        $logpath             = '/var/log/mongodb/mongodb.log'
        $bind_ip             = pick($::xhmongo::globals::bind_ip, ['127.0.0.1'])
        if ($::operatingsystem == 'fedora' and versioncmp($::operatingsystemrelease, '22') >= 0 or
            $::operatingsystem != 'fedora' and versioncmp($::operatingsystemrelease, '7.0') >= 0) {
          $config                  = '/etc/mongod.conf'
          $mongos_config           = '/etc/mongos.conf'
          $pidfilepath             = '/var/run/mongodb/mongod.pid'
          $mongos_pidfilepath      = '/var/run/mongodb/mongos.pid'
          $mongos_unixsocketprefix = '/var/run/mongodb'
          $mongos_logpath          = '/var/log/mongodb/mongodb-shard.log'
          $mongos_fork             = true
        } else {
          $config                  = '/etc/mongodb.conf'
          $mongos_config           = '/etc/mongodb-shard.conf'
          $pidfilepath             = '/var/run/mongodb/mongodb.pid'
          $mongos_pidfilepath      = undef
          $mongos_unixsocketprefix = undef
          $mongos_logpath          = undef
          $mongos_fork             = undef
        }
        $fork                = true
        $journal             = true
      }
    }
    'Debian': {
      if $manage_package {
        $user  = pick($::xhmongo::globals::user, 'mongodb')
        $group = pick($::xhmongo::globals::group, 'mongodb')
        if ($::xhmongo::globals::version == undef) {
          $server_package_name = pick($::xhmongo::globals::server_package_name, 'mongodb-org-server')
          $client_package_name = pick($::xhmongo::globals::client_package_name, 'mongodb-org-shell')
          $mongos_package_name = pick($::xhmongo::globals::mongos_package_name, 'mongodb-org-mongos')
          $package_ensure = true
          $package_ensure_client = true
          $package_ensure_mongos = true
          $service_name = pick($::xhmongo::globals::service_name, 'mongod')
          $config = '/etc/mongod.conf'
        } else {
          # check if the version is greater than 2.6
          if(versioncmp($::xhmongo::globals::version, '2.6.0') >= 0) {
            $server_package_name = pick($::xhmongo::globals::server_package_name, 'mongodb-org-server')
            $client_package_name = pick($::xhmongo::globals::client_package_name, 'mongodb-org-shell')
            $mongos_package_name = pick($::xhmongo::globals::mongos_package_name, 'mongodb-org-mongos')
            $package_ensure = $::xhmongo::globals::version
            $package_ensure_client = $::xhmongo::globals::version
            $package_ensure_mongos = $::xhmongo::globals::version
            $service_name = pick($::xhmongo::globals::service_name, 'mongod')
            $config = '/etc/mongod.conf'
          } else {
            $server_package_name = pick($::xhmongo::globals::server_package_name, 'mongodb-10gen')
            $client_package_name = pick($::xhmongo::globals::client_package_name, 'mongodb-10gen')
            $mongos_package_name = pick($::xhmongo::globals::mongos_package_name, 'mongodb-10gen')
            $package_ensure = $::xhmongo::globals::version
            $package_ensure_client = $::xhmongo::globals::version #this is still needed in case they are only installing the client
            $service_name = pick($::xhmongo::globals::service_name, 'mongodb')
            $config = '/etc/mongodb.conf'
          }
        }
        $mongos_service_name     = pick($::xhmongo::globals::mongos_service_name, 'mongos')
        $mongos_config           = '/etc/mongodb-shard.conf'
        $dbpath                  = '/var/lib/mongodb'
        $logpath                 = '/var/log/mongodb/mongodb.log'
        $pidfilepath             = '/var/run/mongod.pid'
        $bind_ip                 = pick($::xhmongo::globals::bind_ip, ['127.0.0.1'])
      } else {
        # although we are living in a free world,
        # I would not recommend to use the prepacked
        # mongodb server on Ubuntu 12.04 or Debian 6/7,
        # because its really outdated
        if ($::xhmongo::globals::version == undef) {
          $package_ensure = true
          $package_ensure_client = true
          $package_ensure_mongos = true
        } else {
          $package_ensure = $::xhmongo::globals::version
          $package_ensure_client = $::xhmongo::globals::version
          $package_ensure_mongos = $::xhmongo::globals::version
        }
        $user                = pick($::xhmongo::globals::user, 'mongodb')
        $group               = pick($::xhmongo::globals::group, 'mongodb')
        $server_package_name = pick($::xhmongo::globals::server_package_name, 'mongodb-server')
        $client_package_name = $::xhmongo::globals::client_package_name
        $mongos_package_name = pick($::xhmongo::globals::mongos_package_name, 'mongodb-server')
        $service_name        = pick($::xhmongo::globals::service_name, 'mongodb')
        $mongos_service_name = pick($::xhmongo::globals::mongos_service_name, 'mongos')
        $config              = '/etc/mongodb.conf'
        $mongos_config       = '/etc/mongodb-shard.conf'
        $dbpath              = '/var/lib/mongodb'
        $logpath             = '/var/log/mongodb/mongodb.log'
        $bind_ip             = pick($::xhmongo::globals::bind_ip, ['127.0.0.1'])
        $pidfilepath         = $::xhmongo::globals::pidfilepath
      }
      # avoid using fork because of the init scripts design
      $fork                    = undef
      $journal                 = undef
      $mongos_pidfilepath      = undef
      $mongos_unixsocketprefix = undef
      $mongos_logpath          = undef
      $mongos_fork             = undef
    }
    default: {
      fail("Osfamily ${::osfamily} and ${::operatingsystem} is not supported")
    }
  }

  case $::operatingsystem {
    'Debian': {
      case $::operatingsystemmajrelease {
        '8': {
          $service_provider = pick($service_provider, 'systemd')
        }
        default: {
          $service_provider = pick($service_provider, 'debian')
        }
      }
    }
    'Ubuntu': {
      $service_provider = pick($service_provider, 'upstart')
    }
    default: {
      $service_provider = undef
    }
  }
}
