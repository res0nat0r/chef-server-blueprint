#
# Cookbook Name:: chef-server-blueprint
#
# Backup chef server to Remote Object Storage(ex: AWS S3, RackSpace CloudFiles, etc)
marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

log "*** in recipe: chef-server-blueprint::chef-ros-backup"

raise "*** ROS gem missing, please add rightscale::install_tools recipes to runlist." unless File.exists?("/opt/rightscale/sandbox/bin/ros_util")

if (("#{node['chef-server-blueprint']['backup']['storage_account_id']}" == "") ||
    ("#{node['chef-server-blueprint']['backup']['storage_account_secret']}" == "") ||
    ("#{node['chef-server-blueprint']['backup']['container']}" == "") ||
    ("#{node['chef-server-blueprint']['backup']['lineage']}" == ""))
  raise "*** Attributes chef-server-blueprint/backup/storage_account_id, storage_account_secret, container and lineage are required by chef-server-blueprint::chef-ros-backup. Aborting"
end

container = node['chef-server-blueprint']['backup']['container']
cloud = node['chef-server-blueprint']['backup']['storage_account_provider']
backup_script = ::File.join(::File.dirname(__FILE__), "..", "files", "default", "chef-backup.sh")

# Overrides default endpoint or for generic storage clouds such as Swift.
# Is set as ENV['STORAGE_OPTIONS'] for ros_util.
require 'json'

options =
  if node['chef-server-blueprint']['backup']['storage_account_endpoint'].to_s.empty?
    {}
  else
    {'STORAGE_OPTIONS' => JSON.dump({
      :endpoint => node['chef-server-blueprint']['backup']['storage_account_endpoint'],
      :cloud => node['chef-server-blueprint']['backup']['storage_account_provider'].to_sym
    })}
  end

environment_variables = {
  'STORAGE_ACCOUNT_ID' => node['chef-server-blueprint']['backup']['storage_account_id'],
  'STORAGE_ACCOUNT_SECRET' => node['chef-server-blueprint']['backup']['storage_account_secret']
}.merge(options)

backup_src = "/var/backups/chef-backup/chef-backup.tar.bz2"
backup_dst = node['chef-server-blueprint']['backup']['lineage'] + "-" + Time.now.strftime("%Y%m%d%H%M") + ".tar.bz2"

bash "*** Uploading '#{backup_src}' to '#{cloud}' container '#{container}/chef-backups/#{backup_dst}'" do
  flags "-ex"
  user "root"
  environment environment_variables
  code <<-EOH
    chmod +x #{backup_script}
    #{backup_script} --backup
    /opt/rightscale/sandbox/bin/ros_util put --container #{container} --cloud #{cloud} --source #{backup_src} --dest "chef-backups/#{backup_dst}"
  EOH
end
