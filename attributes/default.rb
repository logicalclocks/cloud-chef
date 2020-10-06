include_attribute 'tensorflow'
include_attribute 'hops'

default['cloud']['init']['install_dir']                    = '/root'
default['cloud']['init']['version']                        = '0.6'

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