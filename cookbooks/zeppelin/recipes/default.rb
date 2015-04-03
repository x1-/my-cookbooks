#
# Cookbook Name::zeppelin 
# Recipe:: default
#
# Copyright (C) 2015 x1-
#
# All rights reserved - Do Not Redistribute
#
include_recipe "yum-epel"
include_recipe 'java'

yum_repository 'epel' do
  enabled true
end

%w{
  git
  curl
}.each do |pkg|
  package pkg do
    action :install
  end
end

#nvm_install 'v0.12.2'  do
#  from_source false
#  alias_as_default true
#  action :create
#end

template '/etc/profile.d/nvm.sh' do
  user 'root'
  source 'nvm.sh.erb'
  mode 0755
end

bash "checkout nvm" do
  code <<-EOH
    git clone #{node[:nvm][:repository]} #{node[:nvm][:directory]} && cd #{node[:nvm][:directory]} && git checkout `git describe --abbrev=0 --tags`
  EOH
  not_if { File.exists?( "#{node[:nvm][:directory]}" ) }
end

bash "install node.js #{node[:nvm][:install][:version]}" do
  code <<-EOH
    source /etc/profile.d/nvm.sh
    nvm install #{node[:nvm][:install][:version]}
    nvm use #{node[:nvm][:install][:version]}
  EOH
end

if node[:nvm][:create_default_alias]
  bash "create default alias" do
    code <<-EOH
      source /etc/profile.d/nvm.sh
      nvm alias default #{node[:nvm][:install][:version]}
    EOH
  end
end

