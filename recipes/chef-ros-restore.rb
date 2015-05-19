#
# Cookbook Name:: chef-server-blueprint
#
# Restore chef server from Remote Object Storage(ex: AWS S3, RackSpace CloudFiles, etc)
marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

include_recipe "rsc_ros::default"

log "*** in recipe: chef-server-blueprint::chef-ros-restore"

if ((node['chef-server-blueprint']['backup']['storage_account_id'] == "") ||
    (node['chef-server-blueprint']['backup']['storage_account_secret'] == "") ||
    (node['chef-server-blueprint']['backup']['container'] == "") ||
    (node['chef-server-blueprint']['backup']['lineage'] == ""))
  raise "*** Attributes chef-server-blueprint/backup/storage_account_id, storage_account_secret, container and lineage are required by chef-server-blueprint::chef-ros-backup. Aborting"
end

container = node['chef-server-blueprint']['backup']['container']
cloud = node['chef-server-blueprint']['backup']['storage_account_provider']
prefix = node['chef-server-blueprint']['backup']['lineage']
backup_script = '/usr/local/bin/chef-backup.sh'
include_recipe "rsc_ros::default"

download_file = File.join(Chef::Config[:file_cache_path],"chef-backup.tar.bz2")

rsc_ros download_file do
  storage_provider  cloud
  access_key        node['chef-server-blueprint']['backup']['storage_account_id']
  secret_key        node['chef-server-blueprint']['backup']['storage_account_secret']
  bucket            container
  file              node['chef-server-blueprint']['backup']['lineage']
  destination       download_file
  action            :download
end

cookbook_file backup_script do
  cookbook "chef-server-blueprint"
  source "chef-backup.sh"
  owner "root"
  group "root"
  mode 0777
  action :create
end

bash "*** Downloading latest backup from '#{container}/chef-backups/', cloud #{cloud}" do
  flags "-ex"
  user "root"
  code <<-EOH
    #{backup_script} --restore #{download_file}
  EOH
end
