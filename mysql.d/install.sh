#!/bin/bash
# purpose: install mysql setup on a plain Debian jessie system

set -e
set -u

HOSTNAME="${1}"

SLAVEPASSWD="slavepasswd"
SLAVEUSER="slave_user"

mysql_setup="/.vagrant_mysql_setup"

if [ -e "${mysql_setup}" ] ; then
  echo "Installation procedure for MySQL already executed, exiting to avoid data damage."
  exit 0
fi

if ! grep -q 'iface eth1 inet static' /etc/network/interfaces ; then
  echo "Adding network configuration for eth1 for ceph usage:"

  cat >> /etc/network/interfaces << EOF
# note: added via mysql.d/install.sh
iface eth1 inet static
  address 172.16.0.${HOSTNAME//[^0-9]}
  netmask 255.255.255.0
EOF
fi

# set up internal networking
if ! ip -oneline a s | grep -q 'eth1.*inet 172.16.0' ; then
  ID=${HOSTNAME//[^0-9]} # use '1' for 1st VM, '2' for 2nd VM, '3' for 3rd, etc
  ip addr add "172.16.0.${ID}/24" dev eth1
  ip link set eth1 up
fi

# install proxmox in interactive mode
export "DEBIAN_FRONTEND=noninteractive"

apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade

apt-get -y install mysql-server

touch "${mysql_setup}"

case "${HOSTNAME}" in
  *1)
    mysql -u root -e  "grant replication slave on *.* TO '$SLAVEUSER'@'172.16.0.1/255.255.255.0' identified by '$SLAVEPASSWD'; flush privileges;"
    cat > /etc/mysql/conf.d/synpro.cnf << EOF
[mysqld]
bind-address = 0.0.0.0
server-id = ${HOSTNAME//[^0-9]}
log-bin = mysql-bin
binlog-ignore-db = "mysql"
# avoid "IP address [...] could not be resolved: Name or service not known"
# also see https://www.percona.com/blog/2008/05/31/dns-achilles-heel-mysql-installation/
skip_name_resolve
EOF
    service mysql restart
    mysql -u root << EOF
create database testing;
use testing;
create table users(id int not null auto_increment, primary key(id), username varchar(32) not null);
insert into users (username) values ('foo');
insert into users (username) values ('bar');
EOF
    ;;
  *)
    cat > /etc/mysql/conf.d/synpro.cnf << EOF
[mysqld]
bind-address = 0.0.0.0
server-id = ${HOSTNAME//[^0-9]}
EOF
    service mysql restart
    mysql -u root <<EOF
slave stop;
change master to master_host='172.16.0.1',
master_user='$SLAVEUSER',
master_password='$SLAVEPASSWD';
start slave;
show slave status\G
EOF
    ;;
esac

echo "Finished setup of MySQL."
