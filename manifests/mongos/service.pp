# PRIVATE CLASS: do not call directly
class xhmongo::mongos::service (
  $service_manage   = $xhmongo::mongos::service_manage,
  $service_name     = $xhmongo::mongos::service_name,
  $service_enable   = $xhmongo::mongos::service_enable,
  $service_ensure   = $xhmongo::mongos::service_ensure,
  $service_status   = $xhmongo::mongos::service_status,
  $service_provider = $xhmongo::mongos::service_provider,
  $bind_ip          = $xhmongo::mongos::bind_ip,
  $port             = $xhmongo::mongos::port,
) {

  $service_ensure_real = $service_ensure ? {
    'absent'  => false,
    'purged'  => false,
    'stopped' => false,
    default   => true
  }

  if $port {
    $port_real = $port
  } else {
    $port_real = '27017'
  }

  if $bind_ip == '0.0.0.0' {
    $bind_ip_real = '127.0.0.1'
  } else {
    $bind_ip_real = $bind_ip
  }

  if $::osfamily == 'RedHat' {
    file { '/etc/sysconfig/mongos' :
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => 'OPTIONS="--quiet -f /etc/mongodb-shard.conf"',
      before  => Service['mongos'],
    }
  }

  file { '/etc/init.d/mongos' :
    ensure  => file,
    content => template("mongodb/mongos/${::osfamily}/mongos.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    before  => Service['mongos'],
  }

  if $service_manage {
    service { 'mongos':
      ensure    => $service_ensure_real,
      name      => $service_name,
      enable    => $service_enable,
      provider  => $service_provider,
      hasstatus => true,
      status    => $service_status,
    }

    if $service_ensure_real {
      mongodb_conn_validator { 'mongos':
        server  => $bind_ip_real,
        port    => $port_real,
        timeout => '240',
        require => Service['mongos'],
      }
    }
  }

}
