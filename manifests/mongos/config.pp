# PRIVATE CLASS: do not call directly
class xhmongo::mongos::config (
  $ensure         = $xhmongo::mongos::ensure,
  $config         = $xhmongo::mongos::config,
  $config_content = $xhmongo::mongos::config_content,
  $configdb       = $xhmongo::mongos::configdb,
) {

  if ($ensure == 'present' or $ensure == true) {

    #Pick which config content to use
    if $config_content {
      $config_content_real = $config_content
    } else {
      $config_content_real = template('mongodb/mongodb-shard.conf.erb')
    }

    file { $config:
      content => $config_content_real,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }

  }

}
