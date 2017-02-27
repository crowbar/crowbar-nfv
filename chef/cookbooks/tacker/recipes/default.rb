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
#heat_api_vip = node[:heat][:elements]
heat_api_vip = node[:heat][:elements][:'heat-server']
allowed_hosts = [ "#{sql_host}", node[:hostname], "127.0.0.1", "%"]  
heat_uri = "http://#{heat_api_vip}:8004/v1"
odl_port = "8282"
service_tenant = "services"
myRegion = "RegionOne"
myPassword = "tacker"

Chef::Log.info("BBBBBBBBBBBB #{allowed_hosts}")

Chef::Log.info("ccccccc")
db_settings = fetch_database_settings
Chef::Log.info("DDDDD")
include_recipe "database::client"
include_recipe "#{db_settings[:backend_name]}::client"
include_recipe "#{db_settings[:backend_name]}::python-client"

props = [ {'db_name' => node[:tacker][:db][:database],
          'db_user' => node[:tacker][:db][:user],
          'db_pass' => node[:tacker][:db][:password],
          'db_conn_name' => 'sql_connection'  }
]

Chef::Log.info("This is the db connection #{db_settings[:connection]}")
Chef::Log.info("This is the provider #{db_settings[:provider]}")

props.each do |prop|
  db_name = prop['db_name']
  db_user = prop['db_user']
  db_pass = prop['db_pass']
  db_conn_name = prop['db_conn_name']
  sql_address_name = prop['sql_address_name']

    database "create #{db_name} tacker database" do
        connection db_settings[:connection]
        database_name "#{db_name}"
        provider db_settings[:provider]
        action :create
#        only_if { !ha_enabled || CrowbarPacemakerHelper.is_cluster_founder?(node) }
    end

    database_user "create #{db_user} user in #{db_name} tacker database" do
        connection db_settings[:connection]
        username "#{db_user}"
        password "#{db_pass}"
        host '%'
        provider db_settings[:user_provider]
        action :create
#        only_if { !ha_enabled || CrowbarPacemakerHelper.is_cluster_founder?(node) }
    end

    database_user "grant database access for #{db_user} user in #{db_name} tacker database" do
        connection db_settings[:connection]
        username "#{db_user}"
        password "#{db_pass}"
        database_name "#{db_name}"
        host '%'
        privileges db_settings[:privs]
        provider db_settings[:user_provider]
        action :grant
#        only_if { !ha_enabled || CrowbarPacemakerHelper.is_cluster_founder?(node) }
    end

    node[@cookbook_name][:db][db_conn_name] = "#{db_settings[:url_scheme]}://#{db_user}:#{db_pass}@#{db_settings[:address]}/#{db_name}"
    unless sql_address_name.nil?
        node[@cookbook_name][:db][sql_address_name] = sql_address
    end
end
