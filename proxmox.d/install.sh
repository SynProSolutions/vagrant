#!/bin/bash
# purpose: install Proxmox on a plain Debian stretch system

set -e
set -u

HOSTNAME="${1}"

proxmox_setup="/.vagrant_proxmox_setup"

if [ -e "${proxmox_setup}" ] ; then
  echo "Installation procedure for Proxmox already executed, exiting to avoid data damage."
  exit 0
fi

# eth0 = NAT, eth1 = internal net, eth2 = bridge
EXTERNAL_DEVICE="eth2"
PROXMOX_IP="$(ip --oneline addr show dev "${EXTERNAL_DEVICE}" | awk '{print $4}' | head -1 | sed s';/.*;;')"

cat > /etc/hosts << EOF
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# required for setup of pve-cluster service
${PROXMOX_IP} ${HOSTNAME}.local ${HOSTNAME}

172.16.0.1 node1
172.16.0.2 node2
172.16.0.3 node3
172.16.0.4 node4
172.16.0.5 node5
172.16.0.6 node6
172.16.0.7 node7
172.16.0.8 node8
172.16.0.9 node9
EOF

if ! grep -q 'iface eth1 inet static' /etc/network/interfaces ; then
  echo "Adding network configuration for eth1 for ceph usage:"

  cat >> /etc/network/interfaces << EOF
# note: added via proxmox.d/install.sh - required for pveceph support
auto eth1
iface eth1 inet static
  address 172.16.0.${HOSTNAME//[^0-9]}
  netmask 255.255.255.0
EOF
fi

echo "${HOSTNAME}" > /etc/hostname
hostname "$(cat /etc/hostname)"

# ensure we can log in via ssh as root
if ! grep -q '^PermitRootLogin yes' ; then
  sed -i 's;^PermitRootLogin .*;# set by proxmox.d/install.sh\nPermitRootLogin yes;' /etc/ssh/sshd_config
  service ssh restart
fi

# set up internal networking
if ! ip -oneline a s | grep -q 'eth1.*inet 172.16.0' ; then
  ID=${HOSTNAME//[^0-9]} # use '1' for 1st VM, '2' for 2nd VM, '3' for 3rd, etc
  ip addr add "172.16.0.${ID}/24" dev eth1
  ip link set eth1 up
fi

# install proxmox in interactive mode
export "DEBIAN_FRONTEND=noninteractive"

if ! [ -r /etc/apt/sources.list.d/pve-install-repo.list ] ; then
  echo "deb http://download.proxmox.com/debian stretch pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
fi

if ! [ -r /etc/apt/trusted.gpg.d/proxmox.gpg ] ; then
  wget -O /etc/apt/trusted.gpg.d/proxmox.gpg http://download.proxmox.com/debian/proxmox-ve-release-5.x.gpg
fi

# ensure that the file doesn't exist if provisioning was interrupted
# and we run apt-get update once again
rm -f /etc/apt/sources.list.d/pve-enterprise.list

apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade

apt-get -y install proxmox-ve ksm-control-daemon
# avoid duplicates, proxmox packages install /etc/apt/sources.list.d/pve-enterprise.list
rm -f /etc/apt/sources.list.d/pve-install-repo.list

cat > /etc/sysctl.d/proxmox.conf << EOF
net.ipv4.conf.all.rp_filter=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.ip_forward=1
EOF
sysctl -p /etc/sysctl.d/proxmox.conf

# useful packages
apt-get -y install man-db lsof ntp strace telnet

# drop unnecessary packages, smartd failing to run inside VM
if [ "$(dpkg-query -f "\${db:Status-Status} \${db:Status-Eflag}" -W smartd 2>/dev/null)" = "installed ok" ] ; then
  systemctl disable smartd.service || true
  systemctl reset-failed
  apt-get -y --purge remove smartd
fi

# ensure we use the pve-no-subscription repository
if ! [ -r /etc/apt/sources.list.d/pve-install-repo.list ] ; then
  echo "deb http://download.proxmox.com/debian stretch pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
fi
rm -f /etc/apt/sources.list.d/pve-enterprise.list
apt-get update

case "${HOSTNAME}" in
  *1) if ! [ -r /etc/pve/corosync.conf ] ; then
        # create cluster
        pvecm create proxmox-stretch
      fi

      # share ssh keys with further nodes, to automate setup
      if [ -d /vagrant/proxmox.d/ssh/ ] ; then
        echo "Directory /vagrant/proxmox.d/ssh/ exists already, removing it to avoid ssh problems."
        rm -rf /vagrant/proxmox.d/ssh/
      fi

      mkdir -p /vagrant/proxmox.d/ssh/
      cp /root/.ssh/id_rsa /root/.ssh/id_rsa.pub /etc/pve/priv/authorized_keys /vagrant/proxmox.d/ssh/
      ;;
   *) # retrieve ssh stuff from first node
      cp /vagrant/proxmox.d/ssh/* /root/.ssh/
      ssh-keyscan 172.16.0.1 >> ~/.ssh/known_hosts
      # finally add node to cluster
      yes | pvecm add 172.16.0.1 --use_ssh
      ;;
esac

touch "${proxmox_setup}"

case "${HOSTNAME}" in
  *1)
    ;;
  *)
    cat > /usr/local/sbin/ceph-proxmox-setup << EOF
#!/bin/bash

set -e

export "DEBIAN_FRONTEND=noninteractive"

for id in \$(seq 1 "${HOSTNAME//[^0-9]}") ; do
  ssh-keyscan node\$id >> ~/.ssh/known_hosts
  ssh node\$id pveceph install
done

pveceph init --network 172.16.0.0/24
for id in \$(seq 1 "${HOSTNAME//[^0-9]}") ; do
  ssh node\$id pveceph createmon
  ssh node\$id ceph-disk zap /dev/sdb
  ssh node\$id pveceph createosd /dev/sdb
done

mkdir /etc/pve/priv/ceph
cp /etc/ceph/ceph.client.admin.keyring /etc/pve/priv/ceph/synpro-ceph-storage.keyring

# generate list of all nodes, format: 172.16.0.1;172.16.0.2;172.16.0.3
monit=""
for id in \$(seq 1 "${HOSTNAME//[^0-9]}") ; do
  monit="\$monit;172.16.0.\$id;"
done
monit=\${monit%;}
monit=\${monit#;}
monhosts=\${monit//;;/;}

cat > /etc/pve/storage.cfg << __EOF__
dir: local
        path /var/lib/vz
        maxfiles 0
        content rootdir,vztmpl,images,iso

rbd: synpro-ceph-storage
        monhost \$monhosts
        pool rbd
        username admin
        content images
__EOF__

echo Now you should be ready for adding a ceph pool.
EOF

    chmod 775 /usr/local/sbin/ceph-proxmox-setup

    echo "NOTE: please get rid of /vagrant/proxmox.d/ssh/ proxmox.d/ssh once you set up your last proxmox cluster node,"
    echo "      just execute 'rm -rf proxmox.d/ssh' on your host system."

    echo "To set up ceph on the proxmox cluster execute:

  vagrant ssh stretch-$HOSTNAME
  sudo /usr/local/sbin/ceph-proxmox-setup

"
    ;;
esac

echo "Finished setup of Proxmox, web interface available at https://${PROXMOX_IP}:8006/ (root/vagrant)."
