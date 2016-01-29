#
# Cookbook Name:: chef-server-blueprint
# Recipe:: volume
#
# Copyright (C) 2014 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

detach_timeout = node['chef-server-blueprint']['device']['detach_timeout'].to_i
device_nickname = node['chef-server-blueprint']['device']['nickname']
size = node['chef-server-blueprint']['device']['volume_size'].to_i

#execute "set decommission timeout to #{detach_timeout}" do
#  command "rs_config --set decommission_timeout #{detach_timeout}"
#  not_if "[ `rs_config --get decommission_timeout` -eq #{detach_timeout} ]"
#end


# Cloud-specific volume options
volume_options = {}
volume_options[:iops] = node['chef-server-blueprint']['device']['iops'] if node['chef-server-blueprint']['device']['iops']
volume_options[:volume_type] = node['chef-server-blueprint']['device']['volume_type'] if node['chef-server-blueprint']['device']['volume_type']
volume_options[:controller_type] = node['chef-server-blueprint']['device']['controller_type'] if node['chef-server-blueprint']['device']['controller_type']

new_chef_dir = "#{node['chef-server-blueprint']['device']['mount_point']}/chef-server"

# chef-server-blueprint/restore/lineage is empty, creating new volume
if node['chef-server-blueprint']['restore']['lineage'].to_s.empty?
  log "Creating a new volume '#{device_nickname}' with size #{size}"
  rightscale_volume device_nickname do
    size size
    options volume_options
    action [:create, :attach]
  end

  # Filesystem label must be <= 12 chars
  filesystem device_nickname do
    label device_nickname[0,12]
    fstype node['chef-server-blueprint']['device']['filesystem']
    device lazy { node['rightscale_volume'][device_nickname]['device'] }
    mkfs_options node['chef-server-blueprint']['device']['mkfs_options']
    mount node['chef-server-blueprint']['device']['mount_point']
    action [:create, :enable, :mount]
  end
  # chef-server-blueprint/restore/lineage is set, restore from the backup
else
  node.override['chef-server-blueprint']['lineage'] = node['chef-server-blueprint']['restore']['lineage']
  lineage = node['chef-server-blueprint']['restore']['lineage']
  timestamp = node['chef-server-blueprint']['restore']['timestamp']

  message = "Restoring volume '#{device_nickname}' from backup using lineage '#{lineage}'"
  message << " and using timestamp '#{timestamp}'" if timestamp

  log message

  rightscale_backup device_nickname do
    lineage node['chef-server-blueprint']['restore']['lineage']
    timestamp node['chef-server-blueprint']['restore']['timestamp'].to_i if node['chef-server-blueprint']['restore']['timestamp']
    size size
    options volume_options
    action :restore
  end

  directory node['chef-server-blueprint']['device']['mount_point'] do
    recursive true
  end

  mount node['chef-server-blueprint']['device']['mount_point'] do
    fstype node['chef-server-blueprint']['device']['filesystem']
    device lazy { node['rightscale_backup'][device_nickname]['devices'].first }
    action [:mount, :enable]
  end


end

mv '/var/opt/opscode/bookshelf/' do
  
end

directory '/var/opt/opscode/bookshelf/' do
  recursive true
  action :delete
end

link '/var/opt/opscode/bookshelf/' do
  to new_chef_dir
end
  
# Make sure that there is a 'chef' directory on the mount point of the volume
directory new_chef_dir do
  owner 'opscode'
  group 'opscode'
  action :create
end
