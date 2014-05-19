#!/bin/bash

set -e

# config
DISK=sdb
TABLE=msdos

if [ $(id -u) -ne 0 ] ; then
  echo "$0 requires root permissions." >&2
  exit 1
fi

if ! dpkg --list parted | grep -q '^ii' ; then
  apt-get -y install parted
fi

# make sure parted doesn't fail over existing data...
dd if=/dev/zero of=/dev/${DISK} bs=1M count=1
blockdev --rereadpt /dev/${DISK}

parted -s /dev/${DISK} mklabel msdos
parted -s /dev/${DISK} mkpart primary "" 2048s 2048M
parted -s /dev/${DISK} set 1 boot on
parted -s /dev/${DISK} set 1 lvm on
pvcreate -ff -y /dev/${DISK}1
vgcreate main /dev/${DISK}1
vgchange -a y main
lvcreate  -n drbd-playground -L 1024 main

# http://www.drbd.org/users-guide-8.3/s-latency-tuning.html#s-latency-tuning-deadline-scheduler
echo deadline > /sys/block/${DISK}/queue/scheduler
echo 0 > /sys/block/${DISK}/queue/iosched/front_merges
echo 150 > /sys/block/${DISK}/queue/iosched/read_expire
echo 1500 > /sys/block/${DISK}/queue/iosched/write_expire
