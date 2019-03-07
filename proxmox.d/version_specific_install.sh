#!/bin/bash

if [ "$(id -u)" != 0 ] ; then
  echo "Error: please execute this script with root permissions." >&2
  exit 1
fi

# config
CEPH_VERSION="12.2.5-1~bpo90+1"
GPG_PASSWORD="grml"

# ensure dependencies are presetn
which apt-ftparchive &>/dev/null || apt -y install apt-utils
which dget  &>/dev/null || apt -y --no-install-recommends install devscripts
which gpg &>/dev/null || apt -y install gnupg

set -eu -o pipefail
mkdir -p debs
pushd debs >/dev/null
REPOS_DIR=$(pwd)
wget -c \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/libradosstriper1_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/ceph-mgr_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/ceph-mon_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/ceph_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/ceph-osd_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/ceph-base_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/ceph-common_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/python-rados_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/librbd1_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/librgw2_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/librados2_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/python-cephfs_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/libcephfs2_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/python-rbd_"${CEPH_VERSION}"_amd64.deb \
  http://download.ceph.com/debian-luminous/pool/main/c/ceph/python-rgw_"${CEPH_VERSION}"_amd64.deb
  #dget -d -u http://download.ceph.com/debian-luminous/pool/main/c/ceph/ceph_12.2.5-1.dsc
popd >/dev/null

# generates ~/.gnupg iff non-existing, avoids output on stdout in next check
gpg --list-secret-keys &>/dev/null

if ! gpg --list-secret-keys | grep -q '.' ; then
  mkdir -p .gnupg
  chmod 0700 .gnupg
  cat > gpg_genkey <<EOF
     %echo Generating a basic OpenPGP key
     Key-Type: RSA
     Key-Length: 1024
     Subkey-Type: ELG-E
     Subkey-Length: 1024
     Name-Real: Dummy Signing Key
     Name-Comment: dummy
     Name-Email: root@$(hostname)
     Expire-Date: 0
     Passphrase: ${GPG_PASSWORD}
     %pubring signing.key
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done (with password: ${GPG_PASSWORD})
EOF
  gpg --batch --gen-key gpg_genkey
  gpg --import signing.key
fi

echo "Generating local package repository"
pushd debs >/dev/null
#apt-ftparchive sources  . > Sources
apt-ftparchive packages . > Packages
apt-ftparchive release  . > Release
GPG_TTY="$(tty)" ; export GPG_TTY
echo "${GPG_PASSWORD}" | gpg --batch --yes --passphrase-fd 0 --clearsign --output InRelease --detach-sign Release
echo "${GPG_PASSWORD}" | gpg --batch --yes --passphrase-fd 0 --output Release.gpg --detach-sign Release
popd >/dev/null

rm -f /etc/apt/trusted.gpg.d/local.gpg
gpg --output /etc/apt/trusted.gpg.d/local.gpg --export

echo "deb     file:${REPOS_DIR} ./"   > /etc/apt/sources.list.d/local.list
#echo "deb-src file:${REPOS_DIR} ./"  >> /etc/apt/sources.list.d/local.list

apt update

apt install \
  ceph="${CEPH_VERSION}" \
  ceph-base="${CEPH_VERSION}" \
  ceph-common="${CEPH_VERSION}" \
  ceph-mgr="${CEPH_VERSION}" \
  ceph-mon="${CEPH_VERSION}" \
  ceph-osd="${CEPH_VERSION}" \
  libcephfs2="${CEPH_VERSION}" \
  librados2="${CEPH_VERSION}" \
  libradosstriper1="${CEPH_VERSION}" \
  librbd1="${CEPH_VERSION}" \
  librgw2="${CEPH_VERSION}" \
  python-cephfs="${CEPH_VERSION}" \
  python-rados="${CEPH_VERSION}" \
  python-rbd="${CEPH_VERSION}" \
  python-rgw="${CEPH_VERSION}" \
  corosync=2.4.2-pve5 \
  iproute2=4.13.0-3 \
  libcfg6:amd64=2.4.2-pve5 \
  libcmap4:amd64=2.4.2-pve5 \
  libcorosync-common4:amd64=2.4.2-pve5 \
  libcpg4:amd64=2.4.2-pve5 \
  libpve-access-control=5.0-8 \
  libpve-apiclient-perl=2.0-4 \
  libpve-common-perl=5.0-32 \
  libpve-guest-common-perl=2.0-16 \
  libpve-http-server-perl=2.0-9 \
  libpve-storage-perl=5.0-23 \
  libqb0:amd64=1.0.1-1 \
  libquorum5:amd64=2.4.2-pve5 \
  librados2-perl=1.0-5 \
  libtotem-pg5:amd64=2.4.2-pve5 \
  libvotequorum8:amd64=2.4.2-pve5 \
  lxcfs=3.0.0-1 \
  lxc-pve=3.0.0-3 \
  novnc-pve=1.0.0-1 \
  proxmox-ve=5.2-2 \
  proxmox-widget-toolkit=1.0-18 \
  pve-cluster=5.0-27 \
  pve-container=2.0-23 \
  pve-docs=5.2-4 \
  pve-edk2-firmware=1.20180316-1 \
  pve-firewall=3.0-11 \
  pve-firmware=2.0-4 \
  pve-ha-manager=2.0-5 \
  pve-i18n=1.0-6 \
  pve-kernel-4.15.17-3-pve=4.15.17-12 \
  pve-kernel-4.15=5.2-3 \
  pve-libspice-server1=0.12.8-3 \
  pve-manager=5.2-2 \
  pve-qemu-kvm=2.11.1-5 \
  pve-xtermjs=1.0-5 \
  qemu-server=5.0-28 \
  # EOF
