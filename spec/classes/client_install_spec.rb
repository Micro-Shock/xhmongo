require 'spec_helper'

describe 'xhmongo::client::install', :type => :class do
  describe 'it should create package' do
    let(:pre_condition) { ["class xhmongo::client { $ensure = true $package_name = 'mongodb' }", "include xhmongo::client"]}
    it {
      is_expected.to contain_package('mongodb_client').with({
        :ensure => 'present',
        :name   => 'mongodb',
      })
    }
  end
end
