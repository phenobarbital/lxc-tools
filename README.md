lxc-tools
=========

LXC-tools son unas herramientas (Xen-tools-like) para crear plantillas Debian de LXC containers.

LXC es un sistema de contenedores para virtualizar GNU/Linux en espacios aislados (isolated).
Dentro de los contenedores reside otra versión de GNU/Linux, la cual:

 * Posee su propia interfaz de red
 * Se pueden aplicar cuotas de disco/CPU/RAM
 * Se pueden detener, apagar y/o suspender

LXC-tools son un conjunto de scripts que permiten crear contenedores personalizados de GNU/Linux Debian (y otras distribuciones) dentro de un contenedor LXC.
Están basados en las ideas de los Debian xen-tools, que permiten mediante roles, personalizar las aplicaciones dentro de un LXC-container.

* Requerimientos

- lxc
- rsync
- debootstrap (debian, ubuntu, canaima containers)
- lsb-release
- curl
- wget

* Requerimientos para otros tipos de contenedores:

- btrfs-tools (btrfs sub-volume containers)
- lvm2 (lvm-based containers)

* para construir contenedores CentOS se requiere adicionalmente:

- yum
- rpm

Authors:
 Jesus Lara <jesuslarag@gmail.com>
 version: 0.3
 Copyright (C) 2010 Jesus Lara

 Este script es basado en los scripts de:
 lxc-debian: Daniel Lezcano <daniel.lezcano@free.fr>

 Y en los scripts de:
 Copyright (C) 2010 Nigel McNie
