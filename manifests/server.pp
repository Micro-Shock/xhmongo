# This installs a MongoDB server. See README.md for more details.
class xhmongo::server (
  $ensure           = $xhmongo::params::ensure,

  $user             = $xhmongo::params::user,
  $group            = $xhmongo::params::group,

  $config           = $xhmongo::params::config,
  $dbpath           = $xhmongo::params::dbpath,
  $pidfilepath      = $xhmongo::params::pidfilepath,
  $rcfile           = $xhmongo::params::rcfile,

  $service_manage   = $xhmongo::params::service_manage,
  $service_provider = $xhmongo::params::service_provider,
  $service_name     = $xhmongo::params::service_name,
  $service_enable   = $xhmongo::params::service_enable,
  $service_ensure   = $xhmongo::params::service_ensure,
  $service_status   = $xhmongo::params::service_status,

  $package_ensure  = $xhmongo::params::package_ensure,
  $package_name    = $xhmongo::params::server_package_name,

  $logpath         = $xhmongo::params::logpath,
  $bind_ip         = $xhmongo::params::bind_ip,
  $ipv6            = undef,
  $logappend       = true,
  $fork            = $xhmongo::params::fork,
  $port            = undef,
  $journal         = $xhmongo::params::journal,
  $nojournal       = undef,
  $smallfiles      = undef,
  $cpu             = undef,
  $auth            = false,
  $noauth          = undef,
  $verbose         = undef,
  $verbositylevel  = undef,
  $objcheck        = undef,
  $quota           = undef,
  $quotafiles      = undef,
  $diaglog         = undef,
  $directoryperdb  = undef,
  $profile         = undef,
  $maxconns        = undef,
  $oplog_size      = undef,
  $nohints         = undef,
  $nohttpinterface = undef,
  $noscripting     = undef,
  $notablescan     = undef,
  $noprealloc      = undef,
  $nssize          = undef,
  $mms_token       = undef,
  $mms_name        = undef,
  $mms_interval    = undef,
  $replset         = undef,
  $replset_config  = undef,
  $replset_members = undef,
  $configsvr       = undef,
  $shardsvr        = undef,
  $rest            = undef,
  $quiet           = undef,
  $slowms          = undef,
  $keyfile         = undef,
  $key             = undef,
  $set_parameter   = undef,
  $syslog          = undef,
  $config_content  = undef,
  $ssl             = undef,
  $ssl_key         = undef,
  $ssl_ca          = undef,
  $restart         = $xhmongo::params::restart,
  $storage_engine  = undef,

  $create_admin    = $xhmongo::params::create_admin,
  $admin_username  = $xhmongo::params::admin_username,
  $admin_password  = undef,
  $store_creds     = $xhmongo::params::store_creds,
  $admin_roles     = ['userAdmin', 'readWrite', 'dbAdmin',
                      'dbAdminAnyDatabase', 'readAnyDatabase',
                      'readWriteAnyDatabase', 'userAdminAnyDatabase',
                      'clusterAdmin', 'clusterManager', 'clusterMonitor',
                      'hostManager', 'root', 'restore'],

  # Deprecated parameters
  $master          = undef,
  $slave           = undef,
  $only            = undef,
  $source          = undef,
) inherits xhmongo::params {


  if $ssl {
    validate_string($ssl_key, $ssl_ca)
  }

  if ($ensure == 'present' or $ensure == true) {
    if $restart {
      anchor { 'xhmongo::server::start': }->
      class { 'xhmongo::server::install': }->
      # If $restart is true, notify the service on config changes (~>)
      class { 'xhmongo::server::config': }~>
      class { 'xhmongo::server::service': }->
      anchor { 'xhmongo::server::end': }
    } else {
      anchor { 'xhmongo::server::start': }->
      class { 'xhmongo::server::install': }->
      # If $restart is false, config changes won't restart the service (->)
      class { 'xhmongo::server::config': }->
      class { 'xhmongo::server::service': }->
      anchor { 'xhmongo::server::end': }
    }
  } else {
    anchor { 'xhmongo::server::start': }->
    class { '::xhmongo::server::service': }->
    class { '::xhmongo::server::config': }->
    class { '::xhmongo::server::install': }->
    anchor { 'xhmongo::server::end': }
  }

  if $create_admin {
    validate_string($admin_password)

    xhmongo::db { 'admin':
      user     => $admin_username,
      password => $admin_password,
      roles    => $admin_roles
    }

    # Make sure it runs at the correct point
    Anchor['xhmongo::server::end'] -> xhmongo::Db['admin']

    # Make sure it runs before other DB creation
    xhmongo::Db['admin'] -> xhmongo::Db <| title != 'admin' |>
  }

  # Set-up replicasets
  if $replset {
    # Check that we've got either a members array or a replset_config hash
    if $replset_members and $replset_config {
      fail('You can provide either replset_members or replset_config, not both.')
    } elsif !$replset_members and !$replset_config {
      # No members or config provided. Warn about it.
      warning('Replset specified, but no replset_members or replset_config provided.')
    } else {
      if $replset_config {
        validate_hash($replset_config)

        # Copy it to REAL value
        $replset_config_REAL = $replset_config

      } else {
        validate_array($replset_members)

        # Build up a config hash
        $replset_config_REAL = {
          "${replset}" => {
            'ensure'   => 'present',
            'members'  => $replset_members
          }
        }
      }

      # Wrap the replset class
      class { 'xhmongo::replset':
        sets => $replset_config_REAL
      }
      Anchor['xhmongo::server::end'] -> Class['xhmongo::replset']

      # Make sure that the ordering is correct
      if $create_admin {
        Class['xhmongo::replset'] -> xhmongo::Db['admin']
      }

    }
  }
}
