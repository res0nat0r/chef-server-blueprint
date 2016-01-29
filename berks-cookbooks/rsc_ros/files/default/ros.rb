#!/usr/bin/env ruby

require 'rubygems'
require 'fog'
require 'mixlib/cli'
#setup options

class MyCLI
  include Mixlib::CLI

  option :get_put,
    :short => "-t type",
    :long => "--type type",
    :required => true,
    :description => "type: download, upload, sync_up, sync_down"

  option :provider,
    :short       => "-c cloud",
    :long        => "--cloud cloud",
    :required    => true,
    :description => "Cloud name: aws, rackspace, google"

  option :access_key,
    :short       => "-u access_key",
    :long        => "--user ACCESS_KEY",
    :required    => true,
    :description => "access_key: aws_access_key, username, etc"

  option :secret_key,
    :short       => "-p secret_access_key",
    :long        => "--pass secret_access_key",
    :required    => true,
    :description => "secret_access_key: api_key, password, etc"

  option :bucket,
    :short       => "-b bucket",
    :long        => "--bucket bucket",
    :required    => true,
    :description => "bucket: Container where file is stored"

  option :file,
    :short       => "-f file_name",
    :long        => "--file file_name",
    :required    => true,
    :description => "File to download"

  option :destination,
    :short       => "-d destination",
    :long        => "--destination destination",
    :required    => false,
    :description => "Full path to download file (eg: /tmp/file.tar)"

  option :help,
    :short        => "-h",
    :long         => "--help",
    :description  => "Show this message",
    :on           => :tail,
    :boolean      => true,
    :show_options => true,
    :exit         => 0
end

#create a @connection
@cli = MyCLI.new
@cli.parse_options

@credentials={}
case @cli.config[:provider].downcase
when "aws"
  @credentials={
    :provider              => "AWS",
    :aws_access_key_id     => @cli.config[:access_key],
    :aws_secret_access_key => @cli.config[:secret_key]
  }

when "rackspace"
  @credentials={
    :provider           => "Rackspace",
    :rackspace_username => @cli.config[:access_key],
    :rackspace_api_key  => @cli.config[:secret_key]
  }

when "google"
  @credentials={
    :provider                         => "Google",
    :google_storage_access_key_id     => @cli.config[:access_key],
    :google_storage_secret_access_key => @cli.config[:secret_key]
  }
end

@connection = Fog::Storage.new(@credentials)


def download_file()
  bucket = @connection.directories.get(@cli.config[:bucket])
  file   = bucket.files.get(@cli.config[:file])
  dest   = File.open(@cli.config[:destination], "w")

  dest.write(file.body)
  dest.close
end

def upload_file()
  dirs = []
  @connection.directories.each { |dir| dirs<<dir.key }
  if dirs.include?(@cli.config[:bucket])
    bucket = @connection.directories.get(@cli.config[:bucket])
  else
    bucket = @connection.directories.create(:key => @cli.config[:bucket])
  end
  file = bucket.files.create(
    :key    => File.basename(@cli.config[:file]),
    :body   => File.open(@cli.config[:file])
  )
  file.save
end

def sync_up()
  puts 'not implemented yet'
end

def sync_down()
  puts 'not implemented yet'
end

def init(type)
  case type
  when 'download'
    download_file
  when 'upload'
    upload_file
  when 'sync_up'
    sync_up
  when 'sync_down'
    sync_down
  end
end

init(@cli.config[:get_put])
