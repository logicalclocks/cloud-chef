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