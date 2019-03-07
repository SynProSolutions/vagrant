#!/bin/bash

set -e

echo "Running $0 $@"

host="$1"

# make sure sudo can resolve localhost
if ! grep -q "$host" /etc/hosts ; then
  echo "Adding entry for $host to /etc/hosts"
  echo "# Added via $0 on $(date)" >> /etc/hosts
  echo "127.0.0.2 ${host}.example.org ${host}" >> /etc/hosts
fi

# hostname setup
if ! grep -q "$host" /etc/hostname ; then
  echo "Adjusting hostname to $host"
  echo $host > /etc/hostname
  hostname -F /etc/hostname
fi

# for easy switching between systems
if ! grep -q 172.28.128. /etc/hosts ; then
  echo "Adding entries for VMs to /etc/hosts"
  echo "# Added via $0 on $(date)" >> /etc/hosts

  for i in {1..9} ; do
    echo "172.28.128.1${i} buster${i}" >> /etc/hosts
  done

  for i in {1..9} ; do
    echo "172.28.128.9${i} stretch${i}" >> /etc/hosts
  done

  for i in {1..9} ; do
    echo "172.28.128.8${i} jessie${i}" >> /etc/hosts
  done

  for i in {1..9} ; do
    echo "172.28.128.7${i} wheezy${i}" >> /etc/hosts
  done

  for i in {1..9} ; do
    echo "172.28.128.6${i} squeeze${i}" >> /etc/hosts
  done

  for i in {1..9} ; do
    echo "172.28.128.5${i} lenny${i}" >> /etc/hosts
  done
fi
