# SynProSolutions' Vagrant repository

## Purpose

This repository provides everything what's needed to easily get Virtualbox VMs powered with Debian/wheezy 64bit up and running.
We - [SynPro Solutions](http://synpro-solutions.com/) - use this setup to design and test system changes before deploying them to our customers.

## Requirements

* [Vagrant](http://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

## Setup instructions

Start one plain Debian wheezy system:

```
% vagrant up wheezy1 && vagrant ssh wheezy1
```

If you want two Debian wheezy systems (e.g. to test things like H/A or DRBD):

```
% vagrant up wheezy{1,2}
% vagrant ssh wheezy1
```

You can connect from wheezy1 to wheezy2 and vice versa by ssh-ing as user root with password `vagrant` (e.g. `ssh root@wheezy2` from wheezy1 system).

## License

MIT License, see LICENSE file

## Bugs, Problem, Questions?

Drop us a mail to github (at) synpro.solutions
