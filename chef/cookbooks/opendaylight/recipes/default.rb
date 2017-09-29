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

  odl_root = node[:opendaylight][:odl_root] || "/opt/opendaylight"
  odl_conf = "#{odl_root}/etc"
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

  # (mmnelemane): Temporary workaround to avoid Security Group related configurations
  # in neutron and simplify SDN deployment.

  odl_conf_odl = "#{odl_conf}/opendaylight"
  directory "#{odl_conf_odl}/datastore/initial/config" do
    owner "odl"
    group "odl"
    mode "0755"
    action :create
    recursive true
  end

  template "#{odl_conf_odl}/datastore/initial/config/netvirt-aclservice-config.xml" do
    source "netvirt-aclservice-config.xml.erb"
    owner "odl"
    group "odl"
    mode "0640"
    variables(
      security_group_mode: "transparent"
    )
    notifies :restart, "service[opendaylight]", :immediately
  end

  # Stop and Disable opendaylight service if already running
  service "opendaylight" do
    action [:stop, :disable]
  end

  # Remove temporary directories created by previous run of opendaylight service
  %w(#{odl_root}/data #{odl_root}/snapshots
     #{odl_root}/instances #{odl_root}/journal).each do |path|
    directory path do
      recursive true
      action :delete
    end
  end

  # Setup pre-boot features needed for opendaylight. This is a better
  # approach instead of installing features as a client as we do not
  # need to wait for random time for the service to start and features
  # to complete installation.
  boot_features = node[:opendaylight][:features] || "odl-netvirt-openstack,odl-dlux-core"
  Chef::Log.warn("Boot Features: #{boot_features}")
  template "#{odl_conf}/org.apache.karaf.features.cfg" do
    source "org.apache.karaf.features.cfg.erb"
    owner "odl"
    group "odl"
    mode "0640"
    variables(
      features_boot: boot_features
    )
    notifies :restart, "service[opendaylight]", :immediately
  end

  # Start Opendaylight service in clean mode.
  service "opendaylight" do
    supports status: true, restart: true
    action [:enable, :start]
    start_command "#{odl_root}/bin/start clean"
  end

end

