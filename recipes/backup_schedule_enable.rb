#
# Cookbook Name:: chef-server-blueprint
#
marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

file "/etc/cron.hourly/chef_server_backup" do
  content %Q(
#!/bin/sh
rs_run_recipe --policy 'chef-server-blueprint::chef-ros-backup' --name 'chef-server-blueprint::chef-ros-backup' 2>&1 >> /var/log/rs_backup.log
exit 0
  )
  mode 00700
end
