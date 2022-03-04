
cached_file = "cloud-metrics-collector-#{node['cloud']['metrics']['version']}"
source = "#{node['install']['enterprise']['download_url']}/cloud-metrics-collector/#{node['cloud']['metrics']['version']}/#{cached_file}"
remote_file "#{Chef::Config['file_cache_path']}/#{cached_file}" do
  user 'root'
  group 'root'
  source source
  headers get_ee_basic_auth_header()
  sensitive true
  mode 0555
  action :create_if_missing
end


directory node['cloud']['metrics']['dir'] do
    user node['hopsmonitor']['user']
    group node['hopsmonitor']['group']
    mode '0500'
    action :create
end

bash "Setup daemon" do
    user 'root'
    group 'root'
    code <<-EOH
        set -e
        cp #{Chef::Config['file_cache_path']}/#{cached_file} #{node['cloud']['metrics']['dir']}/cloud-metrics-collector
        chmod 750 #{node['cloud']['metrics']['dir']}/cloud-metrics-collector
        chown #{node['hopsmonitor']['user']}:#{node['hopsmonitor']['group']} #{node['cloud']['metrics']['dir']}/cloud-metrics-collector
    EOH
    not_if { File.exist? "#{node['cloud']['metrics']['dir']}/cloud-metrics-collector" }
end

template "#{node['cloud']['metrics']['dir']}/config.yml" do
  source "metrics_config.yml.erb" 
  owner node['hopsmonitor']['user']
  group node['hopsmonitor']['group']
  mode '0700'
  action :create  
end

case node['platform_family']
when "rhel"
  systemd_script = "/usr/lib/systemd/system/cloud-metrics-collector.service" 
else
  systemd_script = "/lib/systemd/system/cloud-metrics-collector.service"
end


template systemd_script do
  source "cloud-metrics-collector.service.erb"
  owner "root"
  group "root"
  mode 0664
end


if node['kagent']['enabled'] == "true"
   kagent_config "cloud-metrics-collector" do
     service "Monitoring"
     restart_agent false
   end
end

if node['services']['enabled'].casecmp?("true")
  systemd_unit "cloud-metrics-collector.service" do
      action :enable
  end
end