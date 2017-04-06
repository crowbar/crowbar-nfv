db_settings = fetch_database_settings
Chef::Log.info("These are the db_settings: #{db_settings}")
include_recipe "database::client"
include_recipe "#{db_settings[:backend_name]}::client"
include_recipe "#{db_settings[:backend_name]}::python-client"

prop = { "db_name" => node[:tacker][:db][:database],
           "db_user" => node[:tacker][:db][:user],
           "db_pass" => node[:tacker][:db][:password],
           "db_conn_name" => "sql_connection" }

db_name = prop["db_name"]
db_user = prop["db_user"]
db_pass = prop["db_pass"]

database "create db_name tacker database" do
  connection db_settings[:connection]
  database_name db_name
  provider db_settings[:provider]
  action :create
  only_if { !ha_enabled || CrowbarPacemakerHelper.is_cluster_founder?(node) }
end

database_user "create #{db_user} user in #{db_name} tacker database" do
  connection db_settings[:connection]
  username db_user
  password db_pass
  host "%"
  provider db_settings[:user_provider]
  action :create
  only_if { !ha_enabled || CrowbarPacemakerHelper.is_cluster_founder?(node) }
end

database_user "grant database access for #{db_user} user in #{db_name} tacker database" do
  connection db_settings[:connection]
  username db_user
  password db_pass
  database_name db_name
  host "%"
  privileges db_settings[:privs]
  provider db_settings[:user_provider]
  action :grant
  only_if { !ha_enabled || CrowbarPacemakerHelper.is_cluster_founder?(node) }
end
