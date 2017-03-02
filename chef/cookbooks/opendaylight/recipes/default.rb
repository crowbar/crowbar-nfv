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

if node[:platform_family] == "suse"

  package "opendaylight"

  # change opendaylight primary web portal port. port 8181 is still
  # used as backup port
  template "/opt/opendaylight/etc/jetty.xml" do
    source "jetty.xml.erb"
    owner "odl"
    group "odl"
    mode "0640"
    variables(
      port: node[:opendaylight][:port],
    )
    notifies :restart, 'service[opendaylight]', :immediately
  end

  # Stop and Disable opendaylight service if already running
  service "opendaylight" do
    action [:stop, :enable]
  end

  # Remove temporary directories created by previous run of opendaylight service
  %w[ /opt/opendaylight/data/ /opt/opendaylight/snapshots /opt/opendaylight/instances /opt/opendaylight/journal].each do |path|
    directory path do
      recursive true
      action :delete
    end
  end

  # Start Opendaylight service in clean mode.
  service "opendaylight" do
    supports status: true, restart: true
    action [:enable, :start]
    start_command "/opt/opendaylight/bin/start clean"
  end

  # Karaf takes some time to start ssh server access. This will fail
  # if we try to connect to karaf immediately after service start.
  # Adding 3 retries with 2 seconds granularity. Might tune it later
  # if 2 seconds wait it too much
  bash "install opendaylight features" do
    user "root"
    retries 3
    retry_delay 10
    code <<-EOH
        /opt/opendaylight/bin/client -u karaf feature:install \
        #{node[:opendaylight][:features]} &> /dev/null
    EOH
  end
end

