require 'spec_helper'

describe 'xhmongo::server::install', :type => :class do

  describe 'it should create package and dbpath file' do
    let(:pre_condition) { ["class xhmongo::server { $package_ensure = true $dbpath = '/var/lib/mongo' $user = 'mongodb' $package_name = 'mongodb-server' }", "include xhmongo::server"]}

    it {
      is_expected.to contain_package('mongodb_server').with({
        :ensure => 'present',
        :name   => 'mongodb-server',
      })
    }
  end

end
