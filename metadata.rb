name             'chef-server-blueprint'
maintainer       'Ryan J. Geyer'
maintainer_email 'me@ryangeyer.com'
license          'Apache-2.0'
description      'Installs/Configures chef-server-blueprint'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.5'
chef_version     '>= 12.0'

depends "marker"
depends "packagecloud"
depends "chef-server", '= 5.3.0'
depends "rsc_ros", "~> 0.7.0"

# Support everything the chef-server cookbook supports
%w{ ubuntu redhat centos fedora amazon scientific oracle }.each do |os|
  supports os
end

recipe "chef-server-blueprint::default", "Same as chef-server::default, but with inputs and optional package download"
recipe "chef-server-blueprint::chef-ros-backup", "Backup chef server to Remote Object Storage(ex: AWS S3, RackSpace CloudFiles, etc)"
recipe "chef-server-blueprint::chef-ros-restore", "Restore chef server from a  Remote Object Storage(ex: AWS S3, RackSpace CloudFiles, etc) backup"
recipe "chef-server-blueprint::schedule", "Enables chef-server-blueprint::chef-ros-backup to be run hourly."
recipe "chef-server-blueprint::install-webui", "installs webui"
recipe "chef-server-blueprint::schedule", "Schedule a block storage backup"

attribute "chef-server-blueprint/api_fqdn",
    :display_name => "Chef Server FQDN",
    :required => "required",
    :recipes => [ "chef-server-blueprint::default" ]

attribute "chef-server-blueprint/version",
    :display_name => "Chef Server Version",
    :required => "optional",
    :default => "12.0.8-1.el6",
    :recipes => [ "chef-server-blueprint::default" ]

attribute "chef-server-blueprint/remote_file",
    :display_name => "Chef Server URL",
    :description =>  "Instead of specifying the Chef Server Version, you can provide a URL to a chef-server binary to be downloaded and installed. Ex: http://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chef-server-11.0.12-1.el6.x86_64.rpm",
    :required => "optional",
    :recipes => [ "chef-server-blueprint::default" ]


# Backup attributes
attribute "chef-server-blueprint/backup/lineage",
  :display_name => "Chef Server Backup Lineage",
  :description =>
    "The prefix that will be used to name/locate the backup of a particular" +
    " VPN server. Example: text: companyx_certs",
  :required => "optional",
  :recipes => [
    "chef-server-blueprint::chef-ros-backup",
    "chef-server-blueprint::chef-ros-restore",
	"chef-server-blueprint::backup_schedule_enable"
  ]

attribute "chef-server-blueprint/backup",
  :display_name => "Import/export settings for database dump file management.",
  :type => "hash"

attribute "chef-server-blueprint/backup/storage_account_provider",
  :display_name => "Dump Storage Account Provider",
  :description =>
    "Location where the dump file will be saved." +
    " Used by dump recipes to back up to remote object storage" +
    " (complete list of supported storage locations is in input dropdown)." +
    " Example: s3",
  :required => "optional",
  :default => "aws",
  :choice => [
    "aws",
    "google",
    "rackspace"
  ],
  :recipes => [
    "chef-server-blueprint::chef-ros-backup",
    "chef-server-blueprint::chef-ros-restore",
	"chef-server-blueprint::backup_schedule_enable"
  ]

attribute "chef-server-blueprint/backup/storage_account_id",
  :display_name => "Chef Server Backup Storage Account ID",
  :description =>
    "In order to write the Chef Server backup file to the specified cloud storage location," +
    " you need to provide cloud authentication credentials." +
    " For Amazon S3, use your Amazon access key ID" +
    " (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your" +
    " Rackspace login username (e.g., cred:RACKSPACE_USERNAME)." +
    " For OpenStack Swift the format is: 'tenantID:username'." +
    " Example: cred:AWS_ACCESS_KEY_ID",
  :required => "optional",
  :recipes => [
    "chef-server-blueprint::chef-ros-backup",
    "chef-server-blueprint::chef-ros-restore",
	"chef-server-blueprint::schedule"
  ]

attribute "chef-server-blueprint/backup/storage_account_secret",
  :display_name => "Chef Server Backup Storage Account Secret",
  :description =>
    "In order to write the Chef Server backup file to the specified cloud storage location," +
    " you need to provide cloud authentication credentials." +
    " For Amazon S3, use your AWS secret access key" +
    " (e.g., cred:AWS_SECRET_ACCESS_KEY)." +
    " For Rackspace Cloud Files, use your Rackspace account API key" +
    " (e.g., cred:RACKSPACE_AUTH_KEY). Example: cred:AWS_SECRET_ACCESS_KEY",
  :required => "optional",
  :recipes => [
    "chef-server-blueprint::chef-ros-backup",
    "chef-server-blueprint::chef-ros-restore",
	"chef-server-blueprint::schedule"
  ]

attribute "chef-server-blueprint/backup/storage_account_endpoint",
  :display_name => "Chef Server Backup Storage Endpoint URL",
  :description =>
    "The endpoint URL for the storage cloud. This is used to override the" +
    " default endpoint or for generic storage clouds such as Swift." +
    " Example: http://endpoint_ip:5000/v2.0/tokens",
  :required => "optional",
  :default => "",
  :recipes => [
    "chef-server-blueprint::chef-ros-backup",
    "chef-server-blueprint::chef-ros-restore",
	"chef-server-blueprint::schedule"
  ]

attribute "chef-server-blueprint/backup/container",
  :display_name => "Chef Server Backup Container",
  :description =>
    "The cloud storage location where the dump file will be saved to" +
    " or restored from. For Amazon S3, use the bucket name." +
    " For Rackspace Cloud Files, use the container name." +
    " Example: db_dump_bucket",
  :required => "optional",
  :recipes => [
    "chef-server-blueprint::chef-ros-backup",
    "chef-server-blueprint::chef-ros-restore",
	"chef-server-blueprint::schedule"
  ]
attribute "chef-server-blueprint/schedule/enable",
  :display_name => 'Backup Schedule Enable',
  :description => 'Enable or disable periodic backup schedule',
  :default => 'false',
  :choice => ['true', 'false'],
  :recipes => [	"chef-server-blueprint::schedule"  ],
  :required => 'recommended'

attribute 'chef-server-blueprint/schedule/hour',
  :display_name => 'Backup Schedule Hour',
  :description => "The hour to schedule the backup on. This value should abide by crontab syntax. Use '*' for taking" +
    ' backups every hour. Example: 23',
  :recipes => ['rs-mysql::schedule'],
  :required => 'required'

attribute 'chef-server-blueprint/schedule/minute',
  :display_name => 'Backup Schedule Minute',
  :description => 'The minute to schedule the backup on. This value should abide by crontab syntax. Example: 30',
  :recipes => ['rs-mysql::schedule'],
  :required => 'required'
