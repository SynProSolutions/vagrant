#!/bin/bash

set -e

DEVICE='/dev/mapper/main-drbd--playground'
DRBD_DEVICE='/dev/drbd1'

if [[ "$1" == "stop" ]] ; then
  drbd-overview | grep -q Primary/Secondary && kpartx -d /dev/drbd* &>/dev/null
  /etc/init.d/drbd stop
  dmsetup ls | grep -q -- main-drbd--playground && dmsetup remove main-drbd--playground
  echo "Stopped all drbd/lvm devices"
  exit 0
fi

if [ $(id -u) -ne 0 ] ; then
  echo "Error: $0 requires root permissions." >&2
  exit 1
fi

if ! dpkg --list drbd8-utils | grep -q '^ii' ; then
  apt-get -y install drbd8-utils
fi

if ! dpkg --list kpartx | grep -q '^ii' ; then
  apt-get -y install kpartx
fi

if ! [ -b "${DEVICE}" ] ; then
  echo "Error: ${DEVICE} doesn't exist, executed partition_table.sh already?" >&2
  exit 1
fi

IP1="$(getent hosts wheezy1 | awk '/172.28.128/ {print $1}')"
IP2="$(getent hosts wheezy2 | awk '/172.28.128/ {print $1}')"

if [ -z "$IP1" ] || [ -z "$IP2" ] ; then
  echo "Error: couldn't identify IP addresses." >&2
  exit 1
fi

echo "** Setting up /etc/drbd.d/global_common.conf"
[ -r /etc/drbd.d/global_common.conf.orig ] || cp /etc/drbd.d/global_common.conf /etc/drbd.d/global_common.conf.orig
cat > /etc/drbd.d/global_common.conf << EOF
global {
        usage-count yes;
        # minor-count dialog-refresh disable-ip-verification
}

common {
        protocol C;

        handlers {
                pri-on-incon-degr "/usr/lib/drbd/notify-pri-on-incon-degr.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
                pri-lost-after-sb "/usr/lib/drbd/notify-pri-lost-after-sb.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
                local-io-error "/usr/lib/drbd/notify-io-error.sh; /usr/lib/drbd/notify-emergency-shutdown.sh; echo o > /proc/sysrq-trigger ; halt -f";
                # fence-peer "/usr/lib/drbd/crm-fence-peer.sh";
                # split-brain "/usr/lib/drbd/notify-split-brain.sh root";
                # out-of-sync "/usr/lib/drbd/notify-out-of-sync.sh root";
                # before-resync-target "/usr/lib/drbd/snapshot-resync-target-lvm.sh -p 15 -- -c 16k";
                # after-resync-target /usr/lib/drbd/unsnapshot-resync-target-lvm.sh;
        }

        startup {
                # wfc-timeout degr-wfc-timeout outdated-wfc-timeout wait-after-sb;
        }

        disk {
                # on-io-error fencing use-bmbv no-disk-barrier no-disk-flushes
                # no-disk-drain no-md-flushes max-bio-bvecs
        }

        net {
                # snd‐buf-size rcvbuf-size timeout connect-int ping-int ping-timeout max-buffers
                # max-epoch-size ko-count allow-two-primaries cram-hmac-alg shared-secret
                # after-sb-0pri after-sb-1pri after-sb-2pri data-integrity-alg no-tcp-cork
        }

        syncer {
                # rate after al-extents use-rle cpu-mask verify-alg csums-alg
                rate 100M;
                verify-alg "sha1";
        }
}
EOF

sed -i 's/usage-count yes;/usage-count no;/' /etc/drbd.d/global_common.conf

echo "** Setting up /etc/drbd.d/drbd-playground.res"
cat > /etc/drbd.d/drbd-playground.res << EOF
resource drbd-playground {
    protocol C;

on wheezy1 {
    device     ${DRBD_DEVICE};
    disk       ${DEVICE};
    address    ${IP1}:7789;
    meta-disk  internal;
  }

on wheezy2 {
    device     ${DRBD_DEVICE};
    disk       ${DEVICE};
    address    ${IP2}:7789;
    meta-disk  internal;
  }
}
EOF

if ! /etc/init.d/drbd status &>/dev/null ; then
  echo "** Starting drbd service"
  /etc/init.d/drbd start
fi

if drbd-overview | grep -q 'drbd-playground  Connected' ; then
  echo "** DRBD resource drbd-playground seems to be set up, nothing to do."
else
  echo "** Now you can finalize DRBD setup by executing:

on wheezy1:

  drbdadm create-md drbd-playground
  drbdadm up drbd-playground

on wheezy2:

  drbdadm create-md drbd-playground
  drbdadm up drbd-playground

on wheezy1:

  drbdadm invalidate drbd-playground
  drbdadm primary drbd-playground
"
fi

if [ -b /dev/mapper/drbd1p1 ] ; then
  echo "** /dev/mapper/drbd1p1 is already present, nothing to do"
elif drbd-overview | grep -q 'Connected Secondary/Primary' ; then
  echo "** This is the secondary node, nothing to do regarding partitioning here."
else
  echo "** To set up partition table execute on wheezy1 for example:

  parted -s ${DRBD_DEVICE} mklabel msdos
  # ignore 'Error informing the kernel about modifications to partition /dev/drbd1p1 -- Invalid argument':
  parted -s ${DRBD_DEVICE} mkpart primary ntfs 2048s 256M
  parted -s ${DRBD_DEVICE} mkpart primary ext4 256M 512M
  parted -s ${DRBD_DEVICE} set 1 boot on
  kpartx -av ${DRBD_DEVICE}
"
fi
