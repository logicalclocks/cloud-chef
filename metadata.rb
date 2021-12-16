name 'cloud'
maintainer 'Antonios Kouzoupis'
maintainer_email 'antonios@logicalclocks.com'
license 'Apache License Version 2.0'
description 'Installs/Configures cloud-chef'
long_description 'Installs/Configures cloud-chef'
source_url 'https://github.com/logicalclocks/cloud-chef'
issues_url 'https://github.com/logicalclocks/cloud-chef/issues'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'conda'
depends 'kagent'
depends 'hopsworks'
depends 'hadoop_spark'

recipe "install", "Copies and templates necessary files"
recipe "default", "Creates Anaconda environment and setup systemd unit"
recipe "prepare_upgrade", "Copies and template necessary files needed for upgrade"

attribute "cloud/init/install_dir",
          :description => "Installation directory for ec2_init",
          :type => 'string'

attribute "cloud/init/version",
          :description => "Version of ec2init script",
          :type => 'string'

attribute "cloud/data/mount-point",
          :description => "Mount point of data volume. Default: /hopsworks_data",
          :type => 'string'

attribute "cloud/init/config/hosted_zone",
          :description => "Base hopsworks-cloud domain name",
          :type => 'string'

attribute "cloud/init/config/lets_encrypt_dir",
          :description => "Let's Encrypt installation directory",
          :type => 'string'

attribute "cloud/init/config/dev",
          :description => "Flag to follow development code path",
          :type => 'string'

attribute "cloud/init/config/unmanaged",
          :description => "Flag to indicate unmanaged deployments aka non-Hopsworks.Ai Default: false",
          :type => 'string'

attribute "cloud/init/awscli/url",
          :description => "Download url for AWS CLI",
          :type => 'string'

attribute "cloud/init/docker/ecr-login/url",
          :description => "Download url for Amazon ECR Credential Helper",
          :type => 'string'

attribute "cloud/init/rondb/total_memory_config_multiplier",
          :description => "System available memory to RonDB TotalMemoryConfig multiplier. Default: 0.1",
          :type => 'string'

attribute "cloud/init/rondb/num_cpus_multiplier",
          :description => "System cores to RonDB NumCPUs multiplier. Default: 0.4",
          :type => 'string'

attribute "cloud/collect_logs",
          :description => "Flag to enable collecting logs on the Cloud. Default: true",
          :type => 'string'

attribute "cloud/cloudwatch/agent_version",
          :description => "CloudWatch agent version",
          :type => 'string'

attribute "cloud/cloudwatch/download_url",
          :description => "Download URL for CloudWatch agent",
          :type => 'string'

attribute "cloud/ndb-agent/version",
          :description => "Version of ndb-agent",
          :type => 'string'

attribute "cloud/ndb-agent/log-level",
          :description => "Log level of ndb-agent",
          :type => 'string'

attribute "cloud/metrics/version",
          :description => "version of the cloud-metrics-collector to install",
          :type => 'string'
