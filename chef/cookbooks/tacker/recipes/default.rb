#
# Cookbook Name:: opendaylight
# Recipe:: default
#
# Copyright 2016, SUSE LINUX Products GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

keystone_settings = KeystoneHelper.keystone_settings(node, :tacker)

git "/tmp/tacker" do
    repository "https://github.com/trozet/tacker.git"
    reference "SFC_colorado"
    action :sync
end

git "/tmp/tackerclient" do
    repository "https://github.com/trozet/python-tackerclient.git"
    reference "SFC_refactor"
    action :sync
end

Chef::Log.info("AAAAAAAAAAAAAAAAAA #{keystone_settings["internal_url_host"]}")
Chef::Log.info("AAAAAAAAAAAAAAAAAA #{keystone_settings["admin_auth_url"]}")
Chef::Log.info("AAAAAAAAAAAAAAAAAA #{node[:keystone][:api][:admin_port]}")

bind_port = "8808"
auth_uri = node[:keystone][:api][:versioned_public_URL]
identity_uri = node[:keystone][:api][:admin_URL]
int_addr = node[:crowbar][:network][:os_sdn][:address]
odl_addr = int_addr 
mgmt_addr = node[:crowbar][:network][:admin][:address] 
pub_addr = node[:crowbar][:network][:public][:address] 
rabbit_host = node[:rabbitmq][:address]
rabbit_password = node[:rabbitmq][:password]
sql_host = node[:mysql][:bind_address]
database_connection = "mysql://tacker:tacker#{sql_host}/tacker"
internal_url = "http://#{int_addr}:#{bind_port}"
admin_url = "http://#{mgmt_addr}:#{bind_port}"
public_url = "http://#{pub_addr}:#{bind_port}"
heat_api_vip = node[:heat][:elements]
#heat_api_vip = node[:heat][:elements][:heat-server]
allowed_hosts = 
#heat_uri = "http://#{heat_api_vip}:8004/v1"
odl_port = "8282"
service_tenant = "services"
myRegion = "RegionOne"
myPassword = "tacker"

Chef::Log.info("BBBBBBBBBBBB #{auth_uri}")
Chef::Log.info("BBBBBBBBBBBB #{identity_uri}")
Chef::Log.info("BBBBBBBBBBBB #{int_addr}")
Chef::Log.info("BBBBBBBBBBBB #{odl_addr}")
Chef::Log.info("BBBBBBBBBBBB #{mgmt_addr}")
Chef::Log.info("BBBBBBBBBBBB #{pub_addr}")
Chef::Log.info("BBBBBBBBBBBB #{rabbit_password}")
Chef::Log.info("BBBBBBBBBBBB #{rabbit_host}")
Chef::Log.info("BBBBBBBBBBBB #{sql_host}")
Chef::Log.info("BBBBBBBBBBBB #{database_connection}")
Chef::Log.info("BBBBBBBBBBBB #{internal_url}")
Chef::Log.info("BBBBBBBBBBBB #{admin_url}")
Chef::Log.info("BBBBBBBBBBBB #{public_url}")
Chef::Log.info("BBBBBBBBBBBB #{heat_api_vip}")
#Chef::Log.info("BBBBBBBBBBBB #{heat_uri}")
Chef::Log.info("BBBBBBBBBBBB #{odl_port}")

