# PRIVATE CLASS: do not call directly
class xhmongo::server::config {
  $ensure          = $xhmongo::server::ensure
  $user            = $xhmongo::server::user
  $group           = $xhmongo::server::group
  $config          = $xhmongo::server::config
  $config_content  = $xhmongo::server::config_content

  $dbpath          = $xhmongo::server::dbpath
  $pidfilepath     = $xhmongo::server::pidfilepath
  $logpath         = $xhmongo::server::logpath
  $logappend       = $xhmongo::server::logappend
  $fork            = $xhmongo::server::fork
  $port            = $xhmongo::server::port
  $journal         = $xhmongo::server::journal
  $nojournal       = $xhmongo::server::nojournal
  $smallfiles      = $xhmongo::server::smallfiles
  $cpu             = $xhmongo::server::cpu
  $auth            = $xhmongo::server::auth
  $noath           = $xhmongo::server::noauth
  $create_admin    = $xhmongo::server::create_admin
  $admin_username  = $xhmongo::server::admin_username
  $admin_password  = $xhmongo::server::admin_password
  $store_creds     = $xhmongo::server::store_creds
  $rcfile          = $xhmongo::server::rcfile
  $verbose         = $xhmongo::server::verbose
  $verbositylevel  = $xhmongo::server::verbositylevel
  $objcheck        = $xhmongo::server::objcheck
  $quota           = $xhmongo::server::quota
  $quotafiles      = $xhmongo::server::quotafiles
  $diaglog         = $xhmongo::server::diaglog
  $oplog_size      = $xhmongo::server::oplog_size
  $nohints         = $xhmongo::server::nohints
  $nohttpinterface = $xhmongo::server::nohttpinterface
  $noscripting     = $xhmongo::server::noscripting
  $notablescan     = $xhmongo::server::notablescan
  $noprealloc      = $xhmongo::server::noprealloc
  $nssize          = $xhmongo::server::nssize
  $mms_token       = $xhmongo::server::mms_token
  $mms_name        = $xhmongo::server::mms_name
  $mms_interval    = $xhmongo::server::mms_interval
  $master          = $xhmongo::server::master
  $slave           = $xhmongo::server::slave
  $only            = $xhmongo::server::only
  $source          = $xhmongo::server::source
  $configsvr       = $xhmongo::server::configsvr
  $shardsvr        = $xhmongo::server::shardsvr
  $replset         = $xhmongo::server::replset
  $rest            = $xhmongo::server::rest
  $quiet           = $xhmongo::server::quiet
  $slowms          = $xhmongo::server::slowms
  $keyfile         = $xhmongo::server::keyfile
  $key             = $xhmongo::server::key
  $ipv6            = $xhmongo::server::ipv6
  $bind_ip         = $xhmongo::server::bind_ip
  $directoryperdb  = $xhmongo::server::directoryperdb
  $profile         = $xhmongo::server::profile
  $set_parameter   = $xhmongo::server::set_parameter
  $syslog          = $xhmongo::server::syslog
  $ssl             = $xhmongo::server::ssl
  $ssl_key         = $xhmongo::server::ssl_key
  $ssl_ca          = $xhmongo::server::ssl_ca
  $storage_engine  = $xhmongo::server::storage_engine
  $version         = $xhmongo::server::version

  File {
    owner => $user,
    group => $group,
  }

  if ($logpath and $syslog) { fail('You cannot use syslog with logpath')}

  if ($ensure == 'present' or $ensure == true) {

    # Exists for future compatibility and clarity.
    if $auth {
      $noauth = false
    }
    else {
      $noauth = true
    }
    if $keyfile and $key {
      validate_string($key)
      validate_re($key,'.{6}')
      file { $keyfile:
        content => $key,
        owner   => $user,
        group   => $group,
        mode    => '0400',
      }
    }

    if empty($storage_engine) {
      $storage_engine_internal = undef
    } else {
      $storage_engine_internal = $storage_engine
    }


    #Pick which config content to use
    if $config_content {
      $cfg_content = $config_content
    } elsif (versioncmp($version, '2.6.0') >= 0) {
      # Template uses:
      # - $auth
      # - $bind_ip
      # - $configsvr
      # - $dbpath
      # - $directoryperdb
      # - $fork
      # - $ipv6
      # - $jounal
      # - $keyfile
      # - $logappend
      # - $logpath
      # - $maxconns
      # - $nohttpinteface
      # - $nojournal
      # - $noprealloc
      # - $noscripting
      # - $nssize
      # - $objcheck
      # - $oplog_size
      # - $pidfilepath
      # - $port
      # - $profile
      # - $quota
      # - $quotafiles
      # - $replset
      # - $rest
      # - $set_parameter
      # - $shardsvr
      # - $slowms
      # - $smallfiles
      # - $syslog
      # - $verbose
      # - $verbositylevel
      $cfg_content = template('xhmongo/mongodb.conf.2.6.erb')
    } else {
      # Fall back to oldest most basic config
      # Template uses:
      # - $auth
      # - $bind_ip
      # - $configsvr
      # - $cpu
      # - $dbpath
      # - $diaglog
      # - $directoryperdb
      # - $fork
      # - $ipv6
      # - $jounal
      # - $keyfile
      # - $logappend
      # - $logpath
      # - $master
      # - $maxconns
      # - $mms_interval
      # - $mms_name
      # - $mms_token
      # - $noauth
      # - $nohints
      # - $nohttpinteface
      # - $nojournal
      # - $noprealloc
      # - $noscripting
      # - $notablescan
      # - $nssize
      # - $objcheck
      # - $only
      # - $oplog_size
      # - $pidfilepath
      # - $port
      # - $profile
      # - $quiet
      # - $quota
      # - $quotafiles
      # - $replset
      # - $rest
      # - $set_parameter
      # - $shardsvr
      # - $slave
      # - $slowms
      # - $smallfiles
      # - $source
      # - $ssl
      # - $ssl_ca
      # - $ssl_key
      # - storage_engine_internal
      # - $syslog
      # - $verbose
      # - $verbositylevel
      $cfg_content = template('xhmongo/mongodb.conf.erb')
    }

    file { $config:
      content => $cfg_content,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

    file { $dbpath:
      ensure  => directory,
      mode    => '0755',
      owner   => $user,
      group   => $group,
      require => File[$config]
    }
  } else {
    file { $dbpath:
      ensure => absent,
      force  => true,
      backup => false,
    }
    file { $config:
      ensure => absent
    }
  }

  if $auth and $store_creds {
    file { $rcfile:
      ensure  => present,
      content => template('xhmongo/mongorc.js.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644'
    }
  } else {
    file { $rcfile:
      ensure => absent
    }
  }
}
