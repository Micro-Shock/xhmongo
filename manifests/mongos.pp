# This installs a Mongo Shard daemon. See README.md for more details.
class xhmongo::mongos (
  $ensure           = $xhmongo::params::mongos_ensure,
  $config           = $xhmongo::params::mongos_config,
  $config_content   = undef,
  $configdb         = $xhmongo::params::mongos_configdb,
  $service_manage   = $xhmongo::params::mongos_service_manage,
  $service_provider = $xhmongo::params::mongos_service_provider,
  $service_name     = $xhmongo::params::mongos_service_name,
  $service_enable   = $xhmongo::params::mongos_service_enable,
  $service_ensure   = $xhmongo::params::mongos_service_ensure,
  $service_status   = $xhmongo::params::mongos_service_status,
  $package_ensure   = $xhmongo::params::package_ensure_mongos,
  $package_name     = $xhmongo::params::mongos_package_name,
  $unixsocketprefix = $xhmongo::params::mongos_unixsocketprefix,
  $pidfilepath      = $xhmongo::params::mongos_pidfilepath,
  $logpath          = $xhmongo::params::mongos_logpath,
  $fork             = $xhmongo::params::mongos_fork,
  $bind_ip          = undef,
  $port             = undef,
  $restart          = $xhmongo::params::mongos_restart,
) inherits xhmongo::params {

  if ($ensure == 'present' or $ensure == true) {
    if $restart {
      anchor { 'xhmongo::mongos::start': }->
      class { 'xhmongo::mongos::install': }->
      # If $restart is true, notify the service on config changes (~>)
      class { 'xhmongo::mongos::config': }~>
      class { 'xhmongo::mongos::service': }->
      anchor { 'xhmongo::mongos::end': }
    } else {
      anchor { 'xhmongo::mongos::start': }->
      class { 'xhmongo::mongos::install': }->
      # If $restart is false, config changes won't restart the service (->)
      class { 'xhmongo::mongos::config': }->
      class { 'xhmongo::mongos::service': }->
      anchor { 'xhmongo::mongos::end': }
    }
  } else {
    anchor { 'xhmongo::mongos::start': }->
    class { '::xhmongo::mongos::service': }->
    class { '::xhmongo::mongos::config': }->
    class { '::xhmongo::mongos::install': }->
    anchor { 'xhmongo::mongos::end': }
  }

}
