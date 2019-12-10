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

recipe "install", "Copies and templates necessary files"
recipe "default", "Creates Anaconda environment and setup systemd unit"

attribute "cloud/init/install_dir",
          :description => "Installation directory for ec2_init",
          :type => 'string'

attribute "cloud/init/version",
          :description => "Version of ec2init script",
          :type => 'string'

attribute "cloud/init/config/lets_encrypt_dir",
          :description => "Let's Encrypt installation directory",
          :type => 'string'