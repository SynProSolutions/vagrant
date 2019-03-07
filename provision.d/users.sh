#!/bin/bash

set -e

echo "Running $0 $@"

# ensure wget is available
if [ "$(dpkg-query -f "\${db:Status-Status}" -W wget 2>/dev/null)" = "not-installed" ] ; then
  apt-get update
  apt-get -y install wget
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

# ensure vagrant user has a password, by default ssh-ing on
# Debian >=jessie no longer works with passwords
if grep -q 'vagrant:!:' /etc/shadow ; then
  echo "Password for user 'vagrant' is unset, setting to 'vagrant' now"
  echo vagrant:vagrant | chpasswd
fi
