bash "remove cloud-environment" do
    user "root"
    group "root"
    cwd "/home/#{node['conda']['user']}"
    code <<-EOF
        #{node['conda']['base_dir']}/bin/conda env remove -y -q -n cloud
    EOF
    only_if "test -d #{node['conda']['base_dir']}/envs/cloud", :user => node['conda']['user']
end

template "/home/#{node['conda']['user']}/cloud-environment.yml" do
    source "cloud-environment.yml.erb"
    user node['conda']['user']
    group node['conda']['group']
    mode 0550
end

bash "create cloud-environment" do
    user node['conda']['user']
    group node['conda']['group']
    cwd "/home/#{node['conda']['user']}"
    environment ({ 'HOME' => ::Dir.home(node['conda']['user']), 'USER' => node['conda']['user'] })    
    code <<-EOF
        #{node['conda']['base_dir']}/bin/conda env create -q --file cloud-environment.yml
    EOF
    not_if "test -d #{node['conda']['base_dir']}/envs/cloud", :user => node['conda']['user']
end
    
bash "install ec2init" do
    user node['conda']['user']
    group node['conda']['group']
    code <<-EOF
      yes | #{node['conda']['base_dir']}/envs/cloud/bin/pip install --no-cache-dir --upgrade #{Chef::Config['file_cache_path']}/ec2init-#{node['cloud']['init']['version']}-py3-none-any.whl
    EOF
    only_if "test -r #{Chef::Config['file_cache_path']}/ec2init-#{node['cloud']['init']['version']}-py3-none-any.whl", :user => node['conda']['user']
end

template "#{node['cloud']['init']['install_dir']}/ec2init/init_hops-ca.sh" do
    source "init_hops-ca.sh.erb"
    user 'root'
    group 'root'
    mode 0500
end

if node['install']['cloud'].casecmp?("aws")
  
  remote_file "#{node['cloud']['init']['install_dir']}/awscliv2.zip" do
    source node['cloud']['init']['awscli']['url']
    user 'root'
    group 'root'
    mode 0500
    action :create
  end

  package "unzip"
  
  bash "unzip and install AWS CLI V2" do
      user 'root'
      group 'root'
      cwd node['cloud']['init']['install_dir']
      code <<-EOH
          set -e
          rm -rf #{node['cloud']['init']['install_dir']}/aws
          unzip #{node['cloud']['init']['install_dir']}/awscliv2.zip
          ./aws/install --update
          rm #{node['cloud']['init']['install_dir']}/awscliv2.zip
      EOH
  end

  directory node['cloud']['init']['docker']['config_dir'] do
    owner "root"
    group "root"
    mode 0500
    action :create
  end

  cookbook_file "#{node['cloud']['init']['docker']['config_dir']}/config.json" do
      source "config.json"
      user 'root'
      group 'root'
      mode 0500
  end

  if exists_local("hopsworks", "default")

    directory "/home/glassfish/.docker" do
      owner "root"
      group "root"
      mode 0500
      action :create
    end
  
    cookbook_file "/home/glassfish/.docker/config.json" do
        source "config.json"
        user 'root'
        group 'root'
        mode 0500
    end
  
  end

  directory node["install"]["aws"]["docker"]["ecr-login_dir"]  do
    owner "root"
    group "root"
    mode 0500
    action :create
  end
  
  remote_file "#{node["install"]["aws"]["docker"]["ecr-login_dir"]}/docker-credential-ecr-login" do
    source node['cloud']['init']['docker']['ecr-login']['url']
    user 'root'
    group 'root'
    mode 0500
    action :create
  end

  link "/usr/local/bin/docker-credential-ecr-login" do
    to "#{node["install"]["aws"]["docker"]["ecr-login_dir"]}/docker-credential-ecr-login"
    user 'root'
    group 'root'
    action :create
  end
  
  if node['cloud']['collect_logs'].casecmp?("true") && node['cloud']['init']['config']['unmanaged'].casecmp?("false")
    template "/opt/aws/amazon-cloudwatch-agent/bin/aws_agent_config.json" do
      source "aws_agent_config.json.erb"
      user 'root'
      group 'root'
      mode 0550
    end
  end
end  

if node['cloud']['init']['config']['unmanaged'].casecmp?("true")
  systemd_unit "unmanaged-ec2init.service" do
    action :enable
  end
end