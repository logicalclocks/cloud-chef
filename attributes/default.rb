include_attribute 'tensorflow'
include_attribute 'hops'
include_attribute 'ndb'
include_attribute 'hopsworks'
include_attribute "conda"
include_attribute "elastic"
include_attribute "hive2"

default['cloud']['init']['install_dir']                    = '/root'
default['cloud']['init']['version']                        = '0.8'

default['cloud']['init']['config']['hosted_zone']          = "cloud.hopsworks.ai"
default['cloud']['init']['config']['lets_encrypt_dir']     = "/etc/letsencrypt"
default['cloud']['init']['config']['dev']                  = "false"
default['cloud']['init']['config']['unmanaged']            = "false"

default['cloud']['init']['awscli']['url']                  = "#{node['download_url']}/cloud/awscli-exe-linux-x86_64.zip"
default['cloud']['init']['docker']['config_dir']           = "/root/.docker"
default['cloud']['init']['docker']['ecr-login']['version'] = "0.4.0"
default['cloud']['init']['docker']['ecr-login']['url']     = "#{node['download_url']}/cloud/ecr-login/#{node['cloud']['init']['docker']['ecr-login']['version']}/docker-credential-ecr-login"

default['cloud']['init']['gpu']['driver_url']              = node['nvidia']['driver_url']
default['cloud']['init']['gpu']['pkgs_url']                = node['hops']['nvidia_pkgs']['download_url']

default['cloud']['collect_logs']                           = "true"
default['cloud']['cloudwatch']['agent_version']            = "1.247346.1b249759"
default['cloud']['cloudwatch']['download_url']             = "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/#{node['cloud']['cloudwatch']['agent_version']}/amazon-cloudwatch-agent.deb"

default['cloud']['init']['expat_dir']                      = "#{node['cloud']['init']['install_dir']}/expat"