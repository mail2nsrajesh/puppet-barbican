require 'spec_helper'

describe 'barbican::db::sync' do

  shared_examples_for 'barbican-dbsync' do

    it 'runs barbican-manage db upgrade' do
      is_expected.to contain_exec('barbican-db-manage').with(
        :command     => 'barbican-manage db upgrade ',
        :user        => 'barbican',
        :path        => ['/bin','/usr/bin'],
        :refreshonly => 'true',
        :try_sleep   => 5,
        :tries       => 10,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[barbican::install::end]',
                         'Anchor[barbican::config::end]',
                         'Anchor[barbican::dbsync::begin]'],
        :notify      => 'Anchor[barbican::dbsync::end]',
      )
    end

    describe "overriding extra_params" do
      let :params do
        {
          :extra_params => '--config-file /etc/barbican/barbican.conf',
        }
      end

      it {
        is_expected.to contain_exec('barbican-db-manage').with(
          :command     => 'barbican-manage db upgrade --config-file /etc/barbican/barbican.conf',
          :user        => 'barbican',
          :path        => ['/bin','/usr/bin'],
          :refreshonly => 'true',
          :try_sleep   => 5,
          :tries       => 10,
          :logoutput   => 'on_failure',
          :subscribe   => ['Anchor[barbican::install::end]',
                         'Anchor[barbican::config::end]',
                         'Anchor[barbican::dbsync::begin]'],
          :notify      => 'Anchor[barbican::dbsync::end]',
        )
      }
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :os_workers     => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'barbican-dbsync'
    end
  end

end
