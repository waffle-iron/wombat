#
# Cookbook Name:: mock-data
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'cheffish'
Chef::Config.ssl_verify_mode :verify_none

config = {
  :chef_server_url => "https://chef-server",
  :options => {
    :client_name => 'pivotal',
    :signing_key_filename => '/etc/opscode/pivotal.pem'
  }
}

#taken from cheffish
chef_user 'delivery' do
  chef_server config
  admin true
  display_name 'delivery'
  email 'chefeval@chef.io'
  password 'delivery'
  source_key_path "/tmp/private.pem"
end

chef_user 'workstation' do
  chef_server config
  admin true
  display_name 'workstation'
  email 'workstation@chef.io'
  password 'workstation'
  source_key_path "/tmp/private.pem"
end

chef_organization "#{ENV['ORG']}" do
  members ['delivery', 'workstation']
  chef_server config
end

conf_with_org = config.merge({
   :chef_server_url => "#{config[:chef_server_url]}/organizations/#{ENV['ORG']}"
})
  
chef_node "build-node-1" do
  tag 'delivery-build-node'
  chef_server conf_with_org
end

chef_client "build-node-1" do
  source_key_path '/tmp/private.pem'
  chef_server conf_with_org
end

chef_acl "" do
  rights :all, user: %w(delivery workstation)
  recursive true
  chef_server conf_with_org
end

chef_acl "nodes/build-node-1" do
  rights [:read,:write,:update], clients: %w(build-node-1)
  chef_server conf_with_org
end