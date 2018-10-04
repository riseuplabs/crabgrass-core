# -*- mode: ruby -*-
# vi: set ft=ruby :

unless Vagrant.has_plugin?('vagrant-vbguest')
  raise 'Please install the vagrant-vbguest plugin by running `vagrant plugin install vagrant-vbguest`'
end

VAGRANTFILE_API_VERSION = 2
SPHINX_DEV_CONF_PATH = 'config/sphinx/development.conf'.freeze

ruby_version_file = File.join(File.dirname(__FILE__), '.ruby-version')
RUBY_VER = File.exist?(ruby_version_file) ? File.read(ruby_version_file) : '2.1.5'
MYSQL_PASS = ENV['CRABGRASS_MYSQL_PASS'] || 'password' # We don't care, because it is a development VM
MEMORY = (ENV['CRABGRASS_MEMORY'] || 2048).to_i
CPU_COUNT = (ENV['CRABGRASS_CPU_COUNT'] || 2).to_i

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty64'

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :private_network, ip: '192.168.33.10'
  config.vm.synced_folder '.', '/vagrant', nfs: true

  config.vm.provider :virtualbox do |vb|
    vb.name = 'crabgrass_dev'
    vb.memory = MEMORY
    vb.cpus = CPU_COUNT
    vb.customize ['modifyvm', :id, '--cpuexecutioncap', '50']
    # vb.gui = true
  end

  config.vm.provision 'Update the packaqes list', type: 'shell' do |s|
    s.inline = 'sudo apt-get update > /dev/null 2>&1'
  end

  config.vm.provision 'Install the MySQL', type: 'shell', inline: <<-SHELL
    sudo apt-get install -y debconf-utils > /dev/null 2>&1
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password #{MYSQL_PASS}'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password #{MYSQL_PASS}'
    sudo apt-get install -y mysql-server mysql-client libmysqld-dev > /dev/null 2>&1
  SHELL

  config.vm.provision 'Install git, make, libssl, g++, graphicsmagick, inkscape', type: 'shell' do |s|
    s.inline = 'sudo apt-get install -y git make libssl-dev g++ graphicsmagick inkscape > /dev/null 2>&1'
  end

  config.vm.provision 'Install the Sphinxsearch v2.2.10', type: 'shell', inline: <<-SHELL
    sudo add-apt-repository -y ppa:builds/sphinxsearch-rel22 > /dev/null 2>&1
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y sphinxsearch > /dev/null 2>&1
  SHELL

  config.vm.provision "Install RVM and Ruby #{RUBY_VER} and Bundler",
                      type: 'shell', privileged: false, inline: <<-SHELL
      gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 > /dev/null 2>&1
      curl -sSL https://get.rvm.io | bash -s stable > /dev/null 2>&1
      source $HOME/.rvm/scripts/rvm

      rvm use --default --install #{RUBY_VER} > /dev/null 2>&1
      rvm cleanup all
  SHELL

  config.vm.provision 'Install project dependencies', type: 'shell', privileged: false, inline: <<-SHELL
    cd /vagrant/
    bundle install
    rake create_a_secret
  SHELL

  config.vm.provision 'Connect MySQL DB', type: 'shell', privileged: false, inline: <<-SHELL
    cd /vagrant/
    cp config/database.yml.example config/database.yml
    sed -r -i 's|password:|password: #{MYSQL_PASS}|g' config/database.yml
    rake db:create
    rake db:schema:load
    rake db:fixtures:load
  SHELL

  config.vm.provision 'Prepare for testing', type: 'shell', privileged: false, inline: <<-SHELL
    cd /vagrant/
    RAILS_ENV=test bundle install > /dev/null 2>&1
    rake db:test:prepare > /dev/null 2>&1
  SHELL

  # Because of NFS we need to move sphinxsearch lock files and its index from a shared folder.
  # For this we move it to Vagrant user home directory, but keep the logs
  #   at default folder (sed manipulations).
  #
  # Also we call indexer manually bacause the task `rake ts:index`
  #   would rewrite our changed config file.
  config.vm.provision 'Setup Thinking Sphinx Indexes', type: 'shell', privileged: false, inline: <<-SHELL
    cd /vagrant/
    mkdir -p ~/db/sphinx/development/
    mkdir -p ~/tmp/binlog/development/
    mkdir ~/log

    rake ts:configure > /dev/null 2>&1

    sed -r -i 's|/vagrant|/home/vagrant|g' #{SPHINX_DEV_CONF_PATH}
    sed -r -i 's|query_log .*$|query_log = /vagrant/log/development.searchd.query.log|' #{SPHINX_DEV_CONF_PATH}
    sed -r -i 's|log .*$|log = /vagrant/log/development.searchd.log|' #{SPHINX_DEV_CONF_PATH}

    rake cg:test:update_fixtures > /dev/null 2>&1
    rake db:fixtures:load

    indexer --config #{SPHINX_DEV_CONF_PATH} --all > /dev/null 2>&1
  SHELL

  config.vm.provision 'Start Thinking Sphinx', run: 'always', type: 'shell',
                                               privileged: false, inline: <<-SHELL
      cd /vagrant/
      rake ts:start > /dev/null 2>&1
  SHELL

  config.vm.provision 'PROVISIONING COMPLETE!', run: 'always', type: 'shell',
                                                privileged: false, inline: <<-SHELL
      echo -e '\nTo run the server:\n'
      echo -e '\n vagrant ssh\n'
      echo -e '\n cd /vagrant/\n'
      echo -e '\n bin/rails server -b 0.0.0.0\n'
      echo -e '\n(Binding to 0.0.0.0 makes it reachable from the host)\n'
  SHELL

  config.vbguest.auto_reboot = true
  config.vbguest.auto_update = true
end
