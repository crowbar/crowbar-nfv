#
# Copyright 2017, SUSE LINUX GmbH
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

# We are using an old version of tacker and that one is not compatible with postgresql

pkgs = ['mysql', 'python-mysql']
pkgs.push("ruby#{node["languages"]["ruby"]["version"].to_f}-rubygem-mysql")
pkgs.each do |pkg|
  package pkg
end

service 'mysql' do
  action [:start, :enable]
end

# copied from openstack-common/database/db_create_with_user
conn = {
    :host => '127.0.0.1',
    :port => 3306,
    :username => 'root',
  }

database 'create tacker database' do
  provider ::Chef::Provider::Database::Mysql
  connection conn
  database_name node[:tacker][:db][:database]
  action :create
end

# create user
database_user node[:tacker][:db][:user] do
  provider ::Chef::Provider::Database::MysqlUser
  connection conn
  password node[:tacker][:db][:password]
  action :create
end

# grant privs to user
database_user node[:tacker][:db][:user] do
  provider ::Chef::Provider::Database::MysqlUser
  connection conn
  password node[:tacker][:db][:password]
  database_name node[:tacker][:db][:database]
  host '%'
  privileges [:all]
  action :grant
end
