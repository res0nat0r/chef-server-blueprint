rsc_ros Cookbook [![Build Status](https://travis-ci.org/RightScale-Services-Cookbooks/rsc_ros.svg?branch=master)](https://travis-ci.org/RightScale-Services-Cookbooks/rsc_ros)
================
Download from various cloud remote object stores.


Requirements
------------
This cookbook primarily depends on the [fog](http://fog.io) library. This cookbook will install fog and dependencies at boot time.


**NOTE: This cookbook depends on *version 1.29.0* of fog. If you are using a default *v14.1.0* RightScale ServerTemplate, then you must update your *RubyGems* repo in your ServerTemplate to at least *2015-04-23* so that this version of fog can be installed.**

This cookbook has been verified to work with:
* Ubuntu 14.04
* CentOS 6.5



Recipes
-------

| Name                | Description                                |
|---------------------|--------------------------------------------|
| `rsc_ros::default`  | Download and install fog and dependencies. |
| `rsc_ros::download` | Download file from remote object store.    |


Inputs
------


| Name                        | Description                                                                |
|----------------------------|-----------------------------------------------------------------------------|
| `rsc_ros/storage_provider` | Supported storage provider to download remote file.                         |
| `rsc_ros/access_key`       | Access key to authenticate with remote object store.                        |
| `rsc_ros/secret_key`       | Secret key to authenticate with remote object store.                        |
| `rsc_ros/bucket`           | Bucket / container to download remote file.                                 |
| `rsc_ros/file`             | File to download from remote container.                                     |
| `rsc_ros/destination`      | Location on local instance to download file (ex: `/var/tmp/archive.tar.gz)` |

Usage
-----
Just include both scripts above in your boot list and supply the required inputs above.

This cookbook also has a provider which can be called from your code. See `resources/default.rb` for more info.

This cookbook will also install a CLI utility which can be used to download objects `/usr/local/bin/ros_download.rb`:

| Long Option | Short Option    | Description                                                                  |
|-------------|-----------------|------------------------------------------------------------------------------|
| `-c`        | `--cloud`       | Which cloud provider to download from (`aws`, `rackspace`, `google`).        |
| `-u`        | `--user`        | User access key to authenticate with remote object store.                    |
| `-p`        | `--pass`        | Secret access key to authenticate with remote object store.                  |
| `-b`        | `--bucket`      | Bucket / container to download object from.                                  |
| `-f`        | `--file`        | File name to download from container.                                        |
| `-d`        | `--destination` | Location on local instance to download file (ex: `/var/tmp/archive.tar.gz`). |


Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github


License and Authors
-------------------
RightScale Professional Services `<ps@rightscale.com>`
