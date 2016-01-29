#
# Cookbook Name:: chef-server-blueprint
#
marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

file "/etc/cron.hourly/chef_server_backup" do
  backup false
  action :delete
end
