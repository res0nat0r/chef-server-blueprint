require 'spec_helper'

describe 'rsc_ros::default' do
  let(:chef_run_ubuntu) { ChefSpec::Runner.new(platform: 'ubuntu', version: '14.04').converge(described_recipe) }
  let(:chef_run_centos) { ChefSpec::Runner.new(platform: 'centos', version: '6.5').converge(described_recipe) }

  it 'installs required ubuntu packages' do
    expect(chef_run_ubuntu).to install_package('ruby')
    expect(chef_run_ubuntu).to install_package('ruby-dev')
    expect(chef_run_ubuntu).to install_package('make')
    expect(chef_run_ubuntu).to install_package('autoconf')
    expect(chef_run_ubuntu).to install_package('automake')
    expect(chef_run_ubuntu).to install_package('g++')
    expect(chef_run_ubuntu).to install_package('patch')
    expect(chef_run_ubuntu).to install_package('zlib1g-dev')
  end

  it 'installs required centos packages' do
    expect(chef_run_centos).to install_package('ruby19')
    expect(chef_run_centos).to install_package('ruby19-devel')
    expect(chef_run_centos).to install_package('gcc-c++')
    expect(chef_run_centos).to install_package('zlib-devel')
    expect(chef_run_centos).to install_package('patch')
  end

  it 'installs required gems' do
    expect(chef_run_ubuntu).to install_gem_package('fog')
    expect(chef_run_ubuntu).to install_gem_package('mixlib-cli')
  end

  it 'creates /usr/local/bin/ros.rb' do
    expect(chef_run_ubuntu).to create_cookbook_file('/usr/local/bin/ros.rb')
  end
end
