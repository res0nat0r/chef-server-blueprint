#
# Cookbook Name:: rsc_ros
# Recipe:: default
#
# Copyright 2015, RightScale
#
# All rights reserved - Do Not Redistribute
#

# Install package deps
node['rsc_ros']['packages'].each do |pkg|
  package pkg do
    action :install
  end
end

# Install gem deps
node['rsc_ros']['gems'].each_pair do |g, v|
  gem_package g do
    gem_binary "/usr/bin/gem"
    version v
    options("--no-rdoc --no-ri")
    action :install
  end
end

cookbook_file "/usr/local/bin/ros.rb" do
  source "ros.rb"
  owner "root"
  group "root"
  mode 0755
  action :create
end
