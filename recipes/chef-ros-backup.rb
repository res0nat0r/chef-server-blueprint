#
# Cookbook Name:: chef-server-blueprint
#
# Backup chef server to Remote Object Storage(ex: AWS S3, RackSpace CloudFiles, etc)
marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

include_recipe "rsc_ros::default"

log "*** in recipe: chef-server-blueprint::chef-ros-backup"

if ((node['chef-server-blueprint']['backup']['storage_account_id'] == "") ||
    (node['chef-server-blueprint']['backup']['storage_account_secret'] == "") ||
    (node['chef-server-blueprint']['backup']['container'] == "") ||
    (node['chef-server-blueprint']['backup']['lineage'] == ""))
  raise "*** Attributes chef-server-blueprint/backup/storage_account_id, storage_account_secret, container and lineage are required by chef-server-blueprint::chef-ros-backup. Aborting"
end

container = node['chef-server-blueprint']['backup']['container']
cloud = node['chef-server-blueprint']['backup']['storage_account_provider']
backup_script = '/usr/local/bin/chef-backup.sh'

cookbook_file backup_script do
  cookbook "chef-server-blueprint"
  source "chef-backup.sh"
  owner "root"
  group "root"
  mode 0777
  action :create
end

# Overrides default endpoint or for generic storage clouds such as Swift.
# Is set as ENV['STORAGE_OPTIONS'] for ros_util.
require 'json'

backup_dir = '/var/backups/chef-backup'
backup_src = File.join(backup_dir,'chef-backup.tar.bz2')
backup_dst = File.join(backup_dir,node['chef-server-blueprint']['backup']['lineage']+ "-" + Time.now.strftime("%Y%m%d%H%M") + ".tar.bz2")

bash "*** Uploading '#{backup_src}' to '#{cloud}' container '#{container}/chef-backups/#{backup_dst}'" do
  flags "-ex"
  user "root"
  code <<-EOH
#    #{backup_script} --backup
    mv #{backup_src} #{backup_dst}
  EOH
end

rsc_ros "uploading files" do
  storage_provider  cloud
  access_key        node['chef-server-blueprint']['backup']['storage_account_id']
  secret_key        node['chef-server-blueprint']['backup']['storage_account_secret']
  bucket            container
  file              backup_dst
  action            :upload
end
