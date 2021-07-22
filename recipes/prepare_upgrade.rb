expat_filename = ::File.basename(node['hopsworks']['expat_url'])
expat_file = "#{Chef::Config['file_cache_path']}/#{expat_filename}"

remote_file expat_file do
  source node['hopsworks']['expat_url']
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

expat_dir = node['cloud']['init']['expat_dir']
directory expat_dir do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

bash "extract" do
  user "root"
  code <<-EOH
    tar xf #{expat_file} -C #{expat_dir} --strip-components=1
    touch #{expat_dir}/.expat_extracted
  EOH
  action :run
  not_if {::File.exist?("#{expat_dir}/.expat_extracted")}
end

remote_file "#{expat_dir}/lib/mysql-connector-java.jar" do
  source node['hopsworks']['mysql_connector_url']
  owner 'root'
  group 'root'
  mode '0750'
  action :create
end


template "#{expat_dir}/etc/expat-site.xml" do
    source "expat-site.xml.erb"
    owner 'root'
    mode '0750'
    variables ({
        :expat_dir => expat_dir
    })
    action :create
end

template "#{expat_dir}/run_expat.sh" do
    source "run_expat.sh.erb"
    owner 'root'
    mode '0750'
    variables ({
        :expat_dir => expat_dir
    })
    action :create
end

# move base image 
image_url = node['hops']['docker']['base']['download_url']
base_filename = File.basename(image_url)
download_command = " wget #{image_url}"

if node['install']['enterprise']['install'].casecmp? "true"
  image_url ="#{node['install']['enterprise']['download_url']}/docker-tars/#{node['hops']['docker_img_version']}/#{base_filename}"
  download_command = " wget --user #{node['install']['enterprise']['username']} --password #{node['install']['enterprise']['password']} #{image_url}"
end

bash "download_images" do
  user "root"
  group "root"
  sensitive true
  code <<-EOF
       #{download_command} -O #{Chef::Config['file_cache_path']}/#{base_filename}
  EOF
  not_if { File.exist? "#{Chef::Config['file_cache_path']}/#{base_filename}" }
end

bash "copy_images" do
  user "root"
  group "root"
  sensitive true
  code <<-EOF
    cp #{Chef::Config['file_cache_path']}/#{base_filename} #{node['cloud']['init']['install_dir']}/#{base_filename}
  EOF
  not_if { File.exist? "#{node['cloud']['init']['install_dir']}/#{base_filename}" }
end

# move onlinefs image
image_url = node['onlinefs']['download_url']
base_filename = File.basename(image_url)
remote_file "#{Chef::Config['file_cache_path']}/#{base_filename}" do
  source image_url
  action :create
  not_if { File.exist? "#{Chef::Config['file_cache_path']}/#{base_filename}" }
end

bash "copy_images" do
  user "root"
  group "root"
  sensitive true
  code <<-EOF
    cp #{Chef::Config['file_cache_path']}/#{base_filename} #{node['cloud']['init']['install_dir']}/#{base_filename}
  EOF
  not_if { File.exist? "#{node['cloud']['init']['install_dir']}/#{base_filename}" }
end