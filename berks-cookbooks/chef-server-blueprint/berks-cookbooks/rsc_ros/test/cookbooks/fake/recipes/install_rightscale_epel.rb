cookbook_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-RightScale' do
  source 'RPM-GPG-KEY-RightScale'
  owner 'root'
  group 'root'
  mode 0644
end

execute 'import rightscale gpg key' do
  command 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-RightScale'
end

cookbook_file '/etc/yum.repos.d/rightscale-epel.repo' do
  source 'rightscale-epel.repo'
  owner 'root'
  group 'root'
  mode 0644
end
