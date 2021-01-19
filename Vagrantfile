# -*- mode: ruby -*-
# vi: set ft=ruby :

# Generate MAC address for bridged interface, so MAC is the same
# even after restart/recreate, avoids collisions in network though
# still being different for different VMs
# Our MAC as 4 parts: vbox_mac + host_mac + vm_mac_part + dhtest_mac =>
# * vbox_mac     == "0A-00-27" # VirtualBox MAC address prefix
# * host_mac     == 16 bits    # 4 pseudo-random digits generated from hostname of host machine
# * vm_mac_part  == 7 bits     # 2 pseudo-random digits generated from name of guest VM
# * dhtest_mac   == 1 bit      # 1 bit in last digit which allows to have dynamic MACs (real interface MAC=0, dhtest MAC=1)
require "socket"
require 'digest/md5'

def gen_mac(vm_mac_part)
  vbox_mac = "0A0027"
  host_mac = Digest::MD5.hexdigest(Socket.gethostname)[0..3].upcase
  dhtest_mac = 0

  vm_mac_last = (vm_mac_part[1].hex & 0xE | dhtest_mac).to_s(16)

  return vbox_mac + host_mac + vm_mac_part[0] + vm_mac_last
end

# identify public interface automatically
$host_interface = %x[ip route | awk '/^0\.0\.0\.0|default/{printf $NF;exit;}']

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # list of supported systems
  # warning: provision.d/hosts.sh has a hardcoded IP<->hostname list for /etc/hosts
  releases = { lenny: 5, squeeze: 6, wheezy: 7, jessie: 8, stretch: 9, buster: 10, bullseye: 11}

  releases.each do |release, version|
    (1..9).each do |id|
      name = "#{release}#{id}"
      config.vm.define "#{name}" do |system|
        # defaults
        system.vm.box = "https://synpro.solutions/vagrant/debian64_#{release}.box"

        # system specific configuration
        system.vm.network "private_network", ip: "172.28.128.#{version}#{id}"

        system.vm.provision :shell do |shell|
          shell.path = "provision.d/users.sh"
        end

        system.vm.provision :shell do |shell|
          shell.path = "provision.d/hosts.sh"
          shell.args = "#{name}"
        end

        # provider specific configuration
        system.vm.provider "virtualbox" do |vb|
          vb.name = "#{name}"
          # Boot with headless mode by default, to enable GUI mode set:
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
  end

  (1..9).each do |id|
    config.vm.define :"buster-proxmox#{id}" do |proxmox|
      proxmox.vm.box = "https://synpro.solutions/vagrant/debian64_buster.box"
      proxmox.vm.network :forwarded_port, adapter: 1, id: "proxmox",    guest: 8006, host: 8006, auto_correct: true, protocol: "tcp"
      proxmox.vm.network :forwarded_port, adapter: 1, id: "spiceproxy", guest: 3128, host: 3128, auto_correct: true, protocol: "tcp"

      # generate last part of VM MAC based on VM name and add eth2 interface as bridged interface
      vm_mac_part  = Digest::MD5.hexdigest("buster-proxmox#{id}")[0..1].upcase
      proxmox.vm.network :public_network, adapter: 3, bridge: $host_interface, use_dhcp_assigned_default_route: true, mac: gen_mac(vm_mac_part)

      proxmox.vm.provider :virtualbox do |vb|
        vb.name = "buster-proxmox#{id}"
        # configured as 172.16.0.X
        vb.customize ["modifyvm", :id, "--nic2", "intnet"]
        # use 2GB RAM
        vb.customize ["modifyvm", :id, "--memory", "2048"]
        # disable IO-APIC to avoid clock skew, important esp. with ceph
        vb.customize ['modifyvm', :id, '--ioapic', 'off']
        # create 2nd disk with 50GB as optional playground
        disk_dir = File.join(File.dirname(File.expand_path(__FILE__)), "disks/")
        file_to_disk = File.join(disk_dir, "2nd_disk_#{vb.name}.vdi")
        unless File.exist?(file_to_disk)
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 50 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
      end

      proxmox.vm.provision :shell do |shell|
        shell.path = "provision.d/users.sh"
      end

      proxmox.vm.provision :shell do |shell|
        shell.path = "proxmox.d/install.sh"
        shell.args = "proxmox#{id}"
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
