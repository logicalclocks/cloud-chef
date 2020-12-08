bash "Generate versions file" do
    user 'root'
    group 'root'
    cwd node['cloud']['init']['install_dir']
    code <<-EOH
        set -e
        rm -rf #{node['cloud']['init']['install_dir']}/ec2init/versions.csv
        #{node['ndb']['scripts_dir']}/mysql-client.sh -e  "SELECT id, value FROM #{node['hopsworks']['db']}.variables WHERE id LIKE '%version%'" -sN | sed 's/\t/,/g' > #{node['cloud']['init']['install_dir']}/ec2init/versions.csv
    EOH
end

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