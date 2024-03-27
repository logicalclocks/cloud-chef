include_attribute 'tensorflow'
include_attribute 'hops'
include_attribute 'ndb'
include_attribute 'hopsworks'
include_attribute "conda"
include_attribute "elastic"
include_attribute "hive2"
include_attribute "onlinefs"
include_attribute "epipe"
include_attribute "hopsmonitor"

default["cloud"]["install_dir"]                            = node["install"]["dir"].empty? ? "/srv/hops" : node["install"]["dir"]
# Data volume directories
default['cloud']['data_volume']['root_dir']                = "#{node['data']['dir']}/cloud"
default['cloud']['data_volume']['mount-point']             = "/hopsworks_data"
default['cloud']['data_volume']['ec2init_checks']          = "#{node['cloud']['data_volume']['root_dir']}/ec2init_checks"

default['cloud']['init']['install_dir']                    = '/root'
default['cloud']['init']['venv']                           = "cloud-venv"
default['cloud']['init']['version']                        = '0.19'

default['cloud']['init']['config']['hosted_zone']          = "cloud.hopsworks.ai"
default['cloud']['init']['config']['lets_encrypt_dir']     = "/etc/letsencrypt"
default['cloud']['init']['config']['dev']                  = "false"
default['cloud']['init']['config']['unmanaged']            = "false"

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
default['cloud']['init']['awscli']['url']                  = "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
default['cloud']['init']['docker']['config_dir']           = "/root/.docker"
default['cloud']['init']['docker']['ecr-login']['version'] = "0.6.0"
default['cloud']['init']['docker']['ecr-login']['url']     = "#{node['download_url']}/cloud/ecr-login/#{node['cloud']['init']['docker']['ecr-login']['version']}/docker-credential-ecr-login"
default['cloud']['init']['docker']['memory']['soft-limit-multiplier'] = "0.28"
default['cloud']['init']['docker']['memory']['hard-limit-multiplier'] = "0.3"

default['cloud']['init']['gpu']['driver_url']              = node['nvidia']['driver_url']
default['cloud']['init']['gpu']['pkgs_url']                = node['hops']['nvidia_pkgs']['download_url']

default['cloud']['init']['rondb']['total_memory_config_multiplier']  = "0.1"
default['cloud']['init']['rondb']['num_cpus_multiplier']   = "0.4"

default['cloud']['collect_logs']                           = "true"
default['cloud']['cloudwatch']['agent_version']            = "1.247347.6b250880"
default['cloud']['cloudwatch']['download_url']['ubuntu']   = "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/#{node['cloud']['cloudwatch']['agent_version']}/amazon-cloudwatch-agent.deb"
default['cloud']['cloudwatch']['download_url']['centos']   = "https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/#{node['cloud']['cloudwatch']['agent_version']}/amazon-cloudwatch-agent.rpm"

default['cloud']['init']['expat_dir']                      = "#{node['cloud']['init']['install_dir']}/expat"
default['cloud']['ndb-agent']['version']                   = "0.11.0"
default['cloud']['ndb-agent']['base_dir']                  = "#{node['cloud']['install_dir']}/ndb-agent/ndb-agent-#{node['cloud']['ndb-agent']['version']}"
default['cloud']['ndb-agent']['home']                      = "#{node['cloud']['install_dir']}/ndb-agent/ndb-agent"
default['cloud']['ndb-agent']['bin']                       = "#{node['cloud']['ndb-agent']['home']}/bin"
default['cloud']['ndb-agent']['config']                    = "#{node['cloud']['ndb-agent']['home']}/config"
default['cloud']['ndb-agent']['log-level']                 = "debug"
default['cloud']['ndb-agent']['templates-dir']             = "#{node['cloud']['ndb-agent']['home']}/templates"

default['cloud']['metrics']['dir']                         = "#{node["cloud"]["install_dir"]}/cloud-metrics-collector"
default['cloud']['metrics']['version']                     = "0.1.0"

default['cloud']['init']['kubectl']['url']                  = "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
default['cloud']['init']['gcloudcli']['url']               = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-458.0.1-linux-x86_64.tar.gz"
default['cloud']['init']['docker']['gcr-login']['version'] = "2.1.20"
default['cloud']['init']['docker']['gcr-login']['url']     = "#{node['download_url']}/cloud/gcr-login/#{node['cloud']['init']['docker']['gcr-login']['version']}/docker-credential-gcr"
