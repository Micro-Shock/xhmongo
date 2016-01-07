require 'spec_helper'

describe 'xhmongo::mongos' do
  let :facts do
    {
      :osfamily        => 'Debian',
      :operatingsystem => 'Debian',
    }
  end

  let :params do
    {
      :configdb => ['127.0.0.1:27019']
    }
  end

  context 'with defaults' do
    it { is_expected.to contain_class('xhmongo::mongos::install') }
    it { is_expected.to contain_class('xhmongo::mongos::config') }
    it { is_expected.to contain_class('xhmongo::mongos::service') }
  end

  context 'when deploying on Solaris' do
    let :facts do
      { :osfamily        => 'Solaris' }
    end
    it { expect { is_expected.to raise_error(Puppet::Error) } }
  end

end
