node.set['chef-server']['addons'] = []
node['chef-server-blueprint']['addons'].split(',').each do |addon|
  node.set['chef-server']['addons']<< addon
end

include_recipe "chef-server::addons"
