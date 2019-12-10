directory "#{node['cloud']['init']['install_dir']}/ec2init" do
  owner "root"
  group "root"
  mode "700"
end

template "#{node['cloud']['init']['install_dir']}/ec2init/run_ec2_init.sh" do
    source "run_ec2_init.sh.erb"
    user "root"
    group "root"
    mode 0500
end

template "#{node['cloud']['init']['install_dir']}/ec2init/deploy2glassfish_hook.sh" do
  source "deploy2glassfish_hook.sh.erb"
  user "root"
  group "root"
  mode 0500
end

template "#{node['cloud']['init']['install_dir']}/ec2init/ec2init_config.ini" do
  source "ec2init_config.ini.erb"
  user "root"
  group "root"
  mode 0500
end

cached_file = "ec2init-#{node['cloud']['init']['version']}-py3-none-any.whl"
source = "#{node['install']['enterprise']['download_url']}/ec2init/#{node['cloud']['init']['version']}/#{cached_file}"
remote_file "#{Chef::Config['file_cache_path']}/#{cached_file}" do
  user 'root'
  group 'root'
  source source
  headers get_ee_basic_auth_header()
  sensitive true
  mode 0555
  action :create_if_missing
end

case node["platform_family"]
when "debian"
  bash "add certbot repository" do
    user "root"
    group "root"
    code <<-EOF
      apt-get update
      apt-get install -y software-properties-common
      add-apt-repository -y universe
      add-apt-repository -y ppa:certbot/certbot
      apt-get update
    EOF
  end
when "rhel"
  package "epel-release"
end

package "certbot"
package "curl"
