#
# Cookbook Name:: chef-server-blueprint
#
marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

schedule_enable = node['chef-server-blueprint']['schedule']['enable'] == true || node['chef-server-blueprint']['schedule']['enable'] == 'true'
schedule_hour = node['chef-server-blueprint']['schedule']['hour']
schedule_minute = node['chef-server-blueprint']['schedule']['minute']

if schedule_enable
  # Both schedule hour and minute should be set
  unless schedule_hour && schedule_minute
    raise 'chef-server-blueprint/schedule/hour and chef-server-blueprint/schedule/minute inputs should be set'
  end
end

# Adds or removes the crontab entry for backup schedule based on rs-mysql/schedule/enable
cron "Chef Server Backup" do
  minute schedule_minute
  hour schedule_hour
  command "sudo rsc rl10 run_right_script /rll/run/right_script 'RL10 Chef Server Backup'"
  action schedule_enable ? :create : :delete
end