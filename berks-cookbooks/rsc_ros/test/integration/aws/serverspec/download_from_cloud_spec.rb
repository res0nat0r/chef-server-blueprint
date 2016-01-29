require 'serverspec'

set :backend, :exec

describe file('/tmp/archive_download.tar.bz2') do
  it { should be_file }
end
