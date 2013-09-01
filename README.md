lxc-tools
=========

LXC-tools son unas herramientas (Xen-tools-like) para crear plantillas Debian de LXC containers.

LXC-tools son un conjunto de scripts que permiten crear contenedores personalizados de GNU/Linux Debian (y otras distribuciones) dentro de un contenedor LXC.
Están basados en las ideas de los Debian xen-tools, que permiten mediante roles, personalizar las aplicaciones dentro de un LXC-container.

---

lxc-tools are bash-scripts (Debian xen-tools-like) to create LXC containers for various distributions.
You can define roles, post-scripts (hooks) and customize containers in an easy way.

Distributions:
==

- Debian (of course) - Wheezy, Jessie, Sid
- CentOS (6.x)
- Gentoo (last stable stage3)
- Fedora (> 16) (note: build but don't start, systemd start is incompatible with Debian Wheezy)
- Canaima (> auyantepui)

Coming soon:

- ArchLinux (coming soon)
- Ubuntu (coming soon)
- Slack (coming soon)

Requirements

- lxc
- rsync
- debootstrap (debian, ubuntu, canaima containers)
- lsb-release
- curl
- wget

How to install requirements
== 

apt-get install lxc rsync debootstrap lsb-release curl wget

Requirements for CentOS/Fedora Containers
==

apt-get install yum rpm

Requirements for LVM-based or BTRFS-based containers
== 

- btrfs-tools (btrfs sub-volume containers)
- lvm2 (lvm-based containers)


Authors:
 Jesus Lara <jesuslarag@gmail.com>
 version: 0.3
 Copyright (C) 2010 Jesus Lara

 Este script es basado en los scripts de:
 lxc-debian: Daniel Lezcano <daniel.lezcano@free.fr>

 Y en los scripts de:
 Copyright (C) 2010 Nigel McNie
