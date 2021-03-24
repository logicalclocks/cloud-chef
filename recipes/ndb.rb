include_recipe "cloud::default"

directory node['cloud']['ndb-agent']['base_dir'] do
    owner "root"
    group "root"
    mode "700"
    recursive true
end

link node['cloud']['ndb-agent']['home'] do
    owner 'root'
    group 'root'
    to node['cloud']['ndb-agent']['base_dir']
end

directory "#{node['cloud']['ndb-agent']['bin']}" do
    owner "root"
    group "root"
    mode "700"
end

directory "#{node['cloud']['ndb-agent']['config']}" do
    owner "root"
    group "root"
    mode "700"
end

filename = "ndb-agent.tgz"
source = "#{node['install']['enterprise']['download_url']}/ndb-agent/#{node['cloud']['ndb-agent']['version']}/#{filename}"
remote_file "#{Chef::Config['file_cache_path']}/#{filename}" do
    user 'root'
    group 'root'
    source source
    headers get_ee_basic_auth_header()
    sensitive true
    mode 0550
    action :create_if_missing
end

bash "Setup binaries" do
    user 'root'
    group 'root'
    code <<-EOH
        set -e
        tar xzf #{Chef::Config['file_cache_path']}/#{filename} -C #{Chef::Config['file_cache_path']}
        cp #{Chef::Config['file_cache_path']}/ndb-agent/ndb-agent #{node['cloud']['ndb-agent']['bin']}
        chmod 750 #{node['cloud']['ndb-agent']['bin']}/ndb-agent

        cp -r #{Chef::Config['file_cache_path']}/ndb-agent/contrib #{node['cloud']['ndb-agent']['bin']}
        chmod -R 750 #{node['cloud']['ndb-agent']['bin']}/contrib
    EOH
    not_if { File.exist? "#{node['cloud']['ndb-agent']['bin']}/ndb-agent" }
end

template_db_section = false
if exists_local("ndb", "mysqld")
    template_db_section = true
end
template "#{node['cloud']['ndb-agent']['config']}/config.yml" do
    source "ndb-agent/config.yml.erb"
    user 'root'
    group 'root'
    mode 0500
    variables({
        :template_db_section => template_db_section
    })
end

remote_directory "#{node['cloud']['ndb-agent']['templates-dir']}" do
    source 'ndb_templates'
    owner 'root'
    group 'root'
    mode 0750
    files_owner 'root'
    files_group 'root'
    files_mode 0550
end

template "#{node['cloud']['ndb-agent']['templates-dir']}/join_hopsworks_cluster.sh" do
    source "ndb-agent/join_hopsworks_cluster.sh.erb"
    owner 'root'
    group 'root'
    mode 0500
end

case node["platform_family"]
when "debian"
    service_target = "/lib/systemd/system/ndb-agent.service"
when "rhel"
    service_target = "/usr/lib/systemd/system/ndb-agent.service"
end

template service_target do
    source "ndb-agent/ndb-agent.service.erb"
    owner 'root'
    group 'root'
    mode 0644
end

systemd_unit "ndb-agent.service" do
    action :enable
    only_if { node['services']['enabled'].casecmp?("true") }
end