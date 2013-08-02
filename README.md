lxc-tools
=========

LXC-tools son unas herramientas (Xen-tools-like) para crear plantillas Debian de LXC containers.

LXC es un sistema de contenedores para virtualizar GNU/Linux en espacios aislados (isolated).
Dentro de los contenedores reside otra versión de GNU/Linux, la cual:
 * Posee su propia interfaz de red
 * Se pueden aplicar cuotas de disco/CPU/RAM
 * Se pueden detener, apagar y/o suspender

Es un "chroot" mejorado puesto que las facilidades de administración y ejecución basadas en chroot (lxc-execute) pueden ser utilizadas dentro de un contenedor LXC.

LXC-Debian es un script que permite crear contenedores personalizados de GNU/Linux Debian dentro de un
contenedor LXC.

Authors:
 Jesus Lara <jesuslara@devel.com.ve>
 version: 0.1
 Copyright (C) 2010 Jesus Lara

 Este script es basado en los scripts de:
 lxc-debian: Daniel Lezcano <daniel.lezcano@free.fr>

 Y en los scripts de:
 Copyright (C) 2010 Nigel McNie
