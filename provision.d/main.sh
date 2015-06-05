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
  /etc/init.d/hostname.sh
fi

# for easy switching between systems
if ! grep -q 172.28.128.11 /etc/hosts ; then
  echo "Adding entries for wheezy1/wheezy2 to /etc/hosts"
  echo "# Added via $0 on $(date)" >> /etc/hosts
  echo "172.28.128.91 stretch1" >> /etc/hosts
  echo "172.28.128.92 stretch2" >> /etc/hosts
  echo "172.28.128.81 jessie1"  >> /etc/hosts
  echo "172.28.128.82 jessie2"  >> /etc/hosts
  echo "172.28.128.71 wheezy1"  >> /etc/hosts
  echo "172.28.128.72 wheezy2"  >> /etc/hosts
  echo "172.28.128.61 squeeze1" >> /etc/hosts
  echo "172.28.128.62 squeeze2" >> /etc/hosts
  echo "172.28.128.51 lenny1"   >> /etc/hosts
  echo "172.28.128.52 lenny2"   >> /etc/hosts
fi

# config file setup
if ! [ -r /etc/screenrc ] || ! grep -q 'grml' /etc/screenrc ; then
  echo "Installing /etc/screenrc"
  [ -r /etc/screenrc ] && mv /etc/screenrc /etc/screenrc.orig
  wget --quiet -O /etc/screenrc http://git.grml.org/f/grml-etc-core/etc/grml/screenrc_generic
fi

if ! [ -r /etc/vim/vimrc ] || ! grep -q "grml" /etc/vim/vimrc ; then
  echo "Installing /etc/vim/vimrc"
  [ -r /etc/vim/vimrc ] && mv /etc/vim/vimrc /etc/vim/vimrc.orig
  wget --quiet -O /etc/vim/vimrc http://git.grml.org/f/grml-etc-core/etc/vim/vimrc
fi

if ! [ -r /etc/zsh/zshrc ] || ! grep -q 'grml' /etc/zsh/zshrc ; then
  echo "Installing /etc/zsh/zshrc"
  [ -r /etc/zsh/zshrc ] && mv /etc/zsh/zshrc /etc/zsh/zshrc.orig
  wget --quiet -O /etc/zsh/zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
fi

# use zsh as default shell
if ! getent passwd root | grep -q /bin/zsh ; then
  echo "Enabling zsh as default shell for user root"
  chsh -s /bin/zsh root
fi

if ! getent passwd vagrant | grep -q /bin/zsh ; then
  echo "Enabling zsh as default shell for user vagrant"
  chsh -s /bin/zsh vagrant
fi

# zsh shouldn't complain about missing personal file
touch /root/.zshrc
touch /home/vagrant/.zshrc

echo "Updating Debian package information"
apt-get update
