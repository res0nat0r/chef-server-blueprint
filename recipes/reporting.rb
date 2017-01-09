node.set['chef-server']['addons'] << 'reporting'
include_recipe "chef-server::addon"
