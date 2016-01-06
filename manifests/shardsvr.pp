# Wrapper class useful for hiera based deployments

class xhmongo::shardsvr(
  $shards = undef
) {

  if $shards {
    create_resources(mongodb_shard, $shards)
  }

}
