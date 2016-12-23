# SynProSolutions' Vagrant repository

## Purpose

This repository provides everything what's needed to easily get Virtualbox VMs powered with Debian (lenny, squeeze, wheezy, jessie + stretch) 64bit up and running.
We - [SynPro Solutions](http://synpro-solutions.com/) - use this setup to design and test system changes before deploying them to our customers.

## Requirements

* [Vagrant](http://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

## Setup instructions

Start one plain Debian jessie system:

```
% vagrant up jessie1 && vagrant ssh jessie1
```

NOTE: Just replace `jessie` with the Debian release you want to use (`lenny`, `squeeze`, `wheezy`, `jessie` + `stretch` being available).

Nine nodes for each Debian release have been pre-defined (e.g. jessie1, jessie2, jessie3,..., jessie9).
If you need three Debian jessie systems (e.g. to test things like H/A or CEPH):

```
% vagrant up jessie{1,2,3} && vagrant ssh jessie1
```

You can connect between the systems by ssh-ing as user `vagrant` with password `vagrant` (e.g. `ssh vagrant@jessie2` from jessie1 system).

## Vagrant's base box file

The `debian64_lenny.box`, `debian64_squeeze.box`, `debian64_wheezy.box`, `debian64_jessie.box` and `debian64_stretch.box` files which are used for the Debian VMs by Vagrant are generated by [grml-debootstrap](https://github.com/grml/grml-debootstrap) (visit its `packer/` directory for further details).

## License

MIT License, see LICENSE file

## Bugs, Problem, Questions?

Drop us a mail to github (at) synpro.solutions
