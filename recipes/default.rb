#
# Cookbook Name:: chef-server-blueprint
# Recipe:: default
#
# Copyright 2014, Ryan J. Geyer <me@ryangeyer.com>
#
# All rights reserved - Do Not Redistribute
#
marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

node.default["chef-server"]["api_fqdn"] = node["chef-server-blueprint"]["api_fqdn"]
node.default["chef-server"]["version"] = node["chef-server-blueprint"]["version"]

if node['chef-server-blueprint']['remote_file'].nil? || node['chef-server-blueprint']['remote_file'].empty?
  log "*** Input node['chef-server-blueprint']['remote_file'] is undefined, not setting node['chef-server']['package_file']"
else
  filename=""
  if (node['chef-server-blueprint']['remote_file'] =~ /.+\/(.+)$/)
    filename=$1
  else
    throw "*** node['chef-server-blueprint']['remote_file'] with value #{node['chef-server-blueprint']['remote_file']} is not a valid URL, aborting..."
  end

  log "*** Downloading #{node['chef-server-blueprint']['remote_file']} to /root/#{filename}"

  remote_file "/root/#{filename}" do
    source "#{node['chef-server-blueprint']['remote_file']}"
    action :create_if_missing
  end

  log "*** Setting node['chef-server']['package_file'] to /root/#{filename}"
  node['chef-server']['package_file']="/root/#{filename}"
end
p=package "openssl" do
  action :nothing
end
p.run_action(:install)

log "*** setting up ssl root certs"
r=remote_file "/opt/rightscale/sandbox/ssl/certs/ca-bundle.crt" do
    source "http://curl.haxx.se/ca/cacert.pem"
    owner "root"
    group "root"
    mode "0644"
    action :nothing
  end
r.run_action(:create)

r=remote_file "/etc/pki/tls/certs/ca-bundle.crt" do
    source "http://curl.haxx.se/ca/cacert.pem"
    owner "root"
    group "root"
    mode "0644"
    action :nothing
  end
r.run_action(:create)

link "/opt/rightscale/sandbox/ssl/cert.pem" do
  to "/opt/rightscale/sandbox/ssl/certs/ca-bundle.crt"
end

c=cookbook_file "/etc/profile.d/ssl.sh" do
  source "ssl.sh"
  owner "root"
  group "root"
  mode 0777
end
c.run_action(:create)

cookbook_file "/etc/profile.d/chef.sh" do
  source "profile.sh"
  owner "root"
  group "root"
  mode 0777
  action :create
end

log "*** calling packagecloud"
#include_recipe "packagecloud::default"

log "*** Including recipe chef-server::default"
include_recipe "chef-server::default"
