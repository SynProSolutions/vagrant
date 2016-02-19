# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # list of supported systems
  @systems = ["stretch1", "stretch2", "stretch3"]
  @systems.each do |name|
    config.vm.define name do |system|
      # defaults
      system.vm.box = "http://synpro.solutions/vagrant/debian64_stretch.box"

      # system specific configuration
      if name == "stretch1"
        system.vm.network "private_network", ip: "172.28.128.91"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "stretch1"
      elsif name == "stretch2"
        system.vm.network "private_network", ip: "172.28.128.92"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "stretch2"
      elsif name == "stretch3"
        system.vm.network "private_network", ip: "172.28.128.93"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "stretch3"
      end

      # provider specific configuration
      system.vm.provider "virtualbox" do |vb|
        # Don't boot with headless mode
        #vb.gui = true

        # use 1GB RAM
        vb.customize ["modifyvm", :id, "--memory", "1024"]

        # create 2nd disk with 50GB as optional playground
        disk_dir = File.join(File.dirname(File.expand_path(__FILE__)), "disks/")
        file_to_disk = File.join(disk_dir, "2nd_disk_#{name}.vdi")

        unless File.exist?(file_to_disk)
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      end
    end
  end

  # list of supported systems
  @systems = ["jessie1", "jessie2", "jessie3"]
  @systems.each do |name|
    config.vm.define name do |system|
      # defaults
      system.vm.box = "http://synpro.solutions/vagrant/debian64_jessie.box"

      # system specific configuration
      if name == "jessie1"
        system.vm.network "private_network", ip: "172.28.128.81"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "jessie1"
      elsif name == "jessie2"
        system.vm.network "private_network", ip: "172.28.128.82"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "jessie2"
      elsif name == "jessie3"
        system.vm.network "private_network", ip: "172.28.128.83"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "jessie3"
      end

      # provider specific configuration
      system.vm.provider "virtualbox" do |vb|
        # Don't boot with headless mode
        #vb.gui = true

        # use 1GB RAM
        vb.customize ["modifyvm", :id, "--memory", "1024"]

        # create 2nd disk with 50GB as optional playground
        disk_dir = File.join(File.dirname(File.expand_path(__FILE__)), "disks/")
        file_to_disk = File.join(disk_dir, "2nd_disk_#{name}.vdi")

        unless File.exist?(file_to_disk)
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      end
    end
  end

  # list of supported systems
  @systems = ["wheezy1", "wheezy2", "wheezy3"]
  @systems.each do |name|
    config.vm.define name do |system|
      # defaults
      system.vm.box = "http://synpro.solutions/vagrant/debian64_wheezy.box"

      # system specific configuration
      if name == "wheezy1"
        system.vm.network "private_network", ip: "172.28.128.71"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "wheezy1"
      elsif name == "wheezy2"
        system.vm.network "private_network", ip: "172.28.128.72"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "wheezy2"
      elsif name == "wheezy3"
        system.vm.network "private_network", ip: "172.28.128.73"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "wheezy3"
      end

      # provider specific configuration
      system.vm.provider "virtualbox" do |vb|
        # Don't boot with headless mode
        #vb.gui = true

        # use 1GB RAM
        vb.customize ["modifyvm", :id, "--memory", "1024"]

        # create 2nd disk with 50GB as optional playground
        disk_dir = File.join(File.dirname(File.expand_path(__FILE__)), "disks/")
        file_to_disk = File.join(disk_dir, "2nd_disk_#{name}.vdi")

        unless File.exist?(file_to_disk)
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      end
    end
  end

  # list of supported systems
  @systems = ["squeeze1", "squeeze2", "squeeze3"]
  @systems.each do |name|
    config.vm.define name do |system|
      # defaults
      system.vm.box = "http://synpro.solutions/vagrant/debian64_squeeze.box"

      # system specific configuration
      if name == "squeeze1"
        system.vm.network "private_network", ip: "172.28.128.61"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "squeeze1"
      elsif name == "squeeze2"
        system.vm.network "private_network", ip: "172.28.128.62"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "squeeze2"
      elsif name == "squeeze3"
        system.vm.network "private_network", ip: "172.28.128.63"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "squeeze3"
      end

      # provider specific configuration
      system.vm.provider "virtualbox" do |vb|
        # Don't boot with headless mode
        #vb.gui = true

        # use 1GB RAM
        vb.customize ["modifyvm", :id, "--memory", "1024"]

        # create 2nd disk with 50GB as optional playground
        disk_dir = File.join(File.dirname(File.expand_path(__FILE__)), "disks/")
        file_to_disk = File.join(disk_dir, "2nd_disk_#{name}.vdi")

        unless File.exist?(file_to_disk)
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      end
    end
  end

  # list of supported systems
  @systems = ["lenny1", "lenny2", "lenny3"]
  @systems.each do |name|
    config.vm.define name do |system|
      # defaults
      system.vm.box = "http://synpro.solutions/vagrant/debian64_lenny.box"

      # lenny lacks dkms support, Virtualbox Guest Additions aren't available therefore
      system.vm.synced_folder '.', '/vagrant', disabled: true

      # system specific configuration
      if name == "lenny1"
        system.vm.network "private_network", ip: "172.28.128.51"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "lenny1"
      elsif name == "lenny2"
        system.vm.network "private_network", ip: "172.28.128.52"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "lenny2"
      elsif name == "lenny3"
        system.vm.network "private_network", ip: "172.28.128.53"
        system.vm.provision "shell", path: "provision.d/main.sh", args: "lenny3"
      end

      # provider specific configuration
      system.vm.provider "virtualbox" do |vb|
        # Don't boot with headless mode
        #vb.gui = true

        # use 1GB RAM
        vb.customize ["modifyvm", :id, "--memory", "1024"]

        # create 2nd disk with 50GB as optional playground
        disk_dir = File.join(File.dirname(File.expand_path(__FILE__)), "disks/")
        file_to_disk = File.join(disk_dir, "2nd_disk_#{name}.vdi")

        unless File.exist?(file_to_disk)
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      end
    end
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"
  # config.vm.network "private_network", type: "dhcp"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with CFEngine. CFEngine Community packages are
  # automatically installed. For example, configure the host as a
  # policy server and optionally a policy file to run:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.am_policy_hub = true
  #   # cf.run_file = "motd.cf"
  # end
  #
  # You can also configure and bootstrap a client to an existing
  # policy server:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.policy_server_address = "10.0.2.15"
  # end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "site.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end
