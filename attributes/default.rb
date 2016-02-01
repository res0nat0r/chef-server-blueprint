default["chef-server-blueprint"]["version"] = '12.0.8-1.el6'
default['packagecloud']['base_url'] = 'http://packagecloud.io'
default['rsc_ros']['gems']['fog'] = '1.36.0'

# Enable/Disable scheduling backups
default['chef-server-blueprint']['schedule']['enable'] = false

# The hour for the backup schedule
default['chef-server-blueprint']['schedule']['hour'] = nil

# The minute for the backup schedule
default['chef-server-blueprint']['schedule']['minute'] = nil