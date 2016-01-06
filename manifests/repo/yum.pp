# PRIVATE CLASS: do not use directly
class xhmongo::repo::yum inherits xhmongo::repo {
  # We try to follow/reproduce the instruction
  # http://docs.mongodb.org/manual/tutorial/install-mongodb-on-red-hat-centos-or-fedora-linux/

  if($::xhmongo::repo::ensure == 'present' or $::xhmongo::repo::ensure == true) {
    yumrepo { 'mongodb':
      descr          => $::xhmongo::repo::description,
      baseurl        => $::xhmongo::repo::location,
      gpgcheck       => '0',
      enabled        => '1',
      proxy          => $::xhmongo::repo::proxy,
      proxy_username => $::xhmongo::repo::proxy_username,
      proxy_password => $::xhmongo::repo::proxy_password,
    }
    Yumrepo['mongodb'] -> Package<|tag == 'mongodb'|>
  }
  else {
    yumrepo { 'mongodb':
      enabled => absent,
    }
  }
}
