chef-server-blueprint Cookbook
==============================
This is a thin wrapper around chef-server::default which allows me to pass in attribute overrides through RightScale.  I.E. It specifies a couple attributes in the metadata.rb so that RightScale can parse it and present it to the user. Also contains chef-server backup and restore recipes.

Requirements
------------

#### Platform
All the same ones chef-server supports

#### Cookbooks
- `chef-server` - Like I said, this is just a thin wrapper.

Recipes
----------
<table>
  <tr>
    <th>name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>default</tt></td>
    <td>Thin wrapper around chef-server::default which allows me to pass in attribute overrides through RightScale</td>
  </tr>
  <tr>
    <td><tt>chef-ros-backup</tt></td>
    <td>Backup chef server to Remote Object Storage(ex: AWS S3, RackSpace CloudFiles, etc)</td>
  </tr>
  <tr>
    <td><tt>chef-ros-restore</tt></td>
    <td>Restore chef server from a  Remote Object Storage(ex: AWS S3, RackSpace CloudFiles, etc) backup</td>
  </tr>
  <tr>
    <td><tt>backup_schedule_enable</tt></td>
    <td>Enables chef-server-blueprint::chef-ros-backup to be run hourly.</td>
  </tr>
  <tr>
    <td><tt>backup_schedule_disable</tt></td>
    <td>Disables chef-server-blueprint::chef-ros-backup from being run hourly.</td>
  </tr>
</table>


Attributes
----------

It's in the metadata, which is the whole purpose of this cookbook, but...

#### chef-server-blueprint::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chef-server-blueprint']['api_fqdn']</tt></td>
    <td>String</td>
    <td>FQDN for the Web UI and API</td>
    <td><tt>none</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-server-blueprint']['version']</tt></td>
    <td>String</td>
    <td>Chef Server Version</td>
    <td><tt>:latest</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-server-blueprint']['remote_file']</tt></td>
    <td>String</td>
    <td>Chef Server Binary URL</td>
    <td><tt>none</tt></td>
  </tr>
</table>

Usage
-----
#### chef-server-blueprint::default
Just include `chef-server-blueprint` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[chef-server-blueprint]"
  ]
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors:
- Author:: Ryan J. Geyer (me@ryangeyer.com)
