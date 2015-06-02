chef-server-blueprint Cookbook
==============================
Provides recipes for managing a _standalone_ Chef Server with RightScale, including:
* Installation and Configuration of a _standalone_ Chef Server
* Scheduled backups and restore

Github Repository: https://github.com/RightScale-Services-Cookbooks/chef-server-blueprint

# Requirements
* Requires Chef 11 or higher
* Requires Ruby 1.9 or higher
* Platform
  * RHEL/CentOS 5 64-bit
  * RHEL/CentOS 6 64-bit
  * Ubuntu 10.04, 10.10 64-bit
  * Ubuntu 11.04, 11.10 64-bit
  * Ubuntu 12.04, 12.10 64-bit
* Cookbooks
  * [marker](https://supermarket.chef.io/cookbooks/marker)
  * [packagecloud](https://supermarket.chef.io/cookbooks/packagecloud)
  * [rsc_ros](https://github.com/RightScale-Services-Cookbooks/rsc_ros)
  * [chef-server](https://supermarket.chef.io/cookbooks/chef-server)

See the Berksfile and metadata.rb for up to date dependency information.

# Usage
To setup a standalone Chef Server, place the `chef-server-blueprint::default` recipe in the runlist, with the following inputs set:
- `node['chef-server-blueprint'][api_fqdn]` - FQDN of this Chef Server
- `node['chef-server-blueprint'][remote_file]` - Install Chef Server from a remote file instead of specifying `version`. (Optional)
- `node['chef-server-blueprint']['version']` - Version of Chef Server to install (Optional)

## Creating a Backup
To create a manual backup of the Chef Server configuration, run the `chef-server-blueprint::chef-ros-backup` recipe with the following inputs set:
- `node['chef-server-blueprint']['backup']['lineage']` - The prefix that will be used to name/locate the backup of a particular VPN server. 
- `node['chef-server-blueprint']['backup']['storage_account_provider']` - The storage provider where the dump file will be saved. 
- `node['chef-server-blueprint']['backup']['storage_account_id']` - The storage provider authentication user.
- `node['chef-server-blueprint']['backup']['storage_account_secret']` - The storage provider authentication secret/password.
- `node['chef-server-blueprint']['backup']['storage_account_endpoint']` - The endpoint URL for the storage cloud.
- `node['chef-server-blueprint']['backup']['container']` - The cloud storage location where the dump file will be saved to or restored from.

This recipe creates a compressed tar file which is uploaded to a Remote Object Storage location supported by the [rsc_ros](https://github.com/RightScale-Services-Cookbooks/rsc_ros).

### Scheduled Backups
Automation of the manual backup is configured by the `chef-server-blueprint::backup_schedule_enable` and `chef-server-blueprint::backup_schedule_disable` recipes.
These recipes `enable` and `disable` an hourly cron job which executes the `chef-ros-backup1` recipe.

## Restoring from a Backup
```
NOTE: The lineage input currently requires the complete filename in order to restore correctly. This is different from how this input is used for backups and will need to be modified prior to every restore attempt. This will be corrected in a future release.
```
To restore from a Backup, run the `chef-server-blueprint::chef-ros-restore` recipe with the following inputs set:
- `node['chef-server-blueprint']['backup']['lineage']` - *The entire filename of the backup as it was uploaded to remote storage*
- `node['chef-server-blueprint']['backup']['storage_account_provider']` - The storage provider where the dump file will be saved. 
- `node['chef-server-blueprint']['backup']['storage_account_id']` - The storage provider authentication user.
- `node['chef-server-blueprint']['backup']['storage_account_secret']` - The storage provider authentication secret/password.
- `node['chef-server-blueprint']['backup']['storage_account_endpoint']` - The endpoint URL for the storage cloud.
- `node['chef-server-blueprint']['backup']['container']` - The cloud storage location where the dump file will be saved to or restored from.

## Installing the WebUI
To install the WebUI, run the `chef-server-blueprint::install-webui` recipe.

# Attributes
- `node['chef-server-blueprint'][api_fqdn]` - FQDN of this Chef Server
- `node['chef-server-blueprint'][remote_file]` - Install Chef Server from a remote file instead of specifying `version`. (Optional)
- `node['chef-server-blueprint']['version']` - Version of Chef Server to install (Optional)
- `node['chef-server-blueprint']['backup']['lineage']` - The prefix that will be used to name/locate the backup of a particular VPN server. 
- `node['chef-server-blueprint']['backup']['storage_account_provider']` - The storage provider where the dump file will be saved. 
- `node['chef-server-blueprint']['backup']['storage_account_id']` - The storage provider authentication user.
- `node['chef-server-blueprint']['backup']['storage_account_secret']` - The storage provider authentication secret/password.
- `node['chef-server-blueprint']['backup']['storage_account_endpoint']` - The endpoint URL for the storage cloud.
- `node['chef-server-blueprint']['backup']['container']` - The cloud storage location where the dump file will be saved to or restored from.

# Recipes
## `chef-server-blueprint::default`

Installs and configures the instance as a _standalone_ Chef Server using the `version` specified for downloading from package.io *OR* using a user specified `remote_file` to perform the installation.

## `chef-server-blueprint::install-webui`

Installs the Chef Server Web UI.

## `chef-server-blueprint::chef-ros-backup`

Creates a compressed archive backup of the critical Chef Server files and uploads the file to Remote Object Storage provided by the `rsc_ros` cookbook. The backup name is `[lineage]-yyyymmddhhMM.tar.bz2`.

## `chef-server-blueprint::chef-ros-restore`

Restores the compressed archive backup created by the `chef-ros-backup` recipe.

## `chef-server-blueprint::backup-schedule-enable`

Creates a cron entry that runs the `chef-ros-backup` recipe every hour.

## `chef-server-blueprint::backup-schedule-disable`

Removes the cron entry created by `backup-schedule-enable`. 

# Author
