LXC howto
=========

* instalar los requerimientos de LXC
aptitude install bridge-utils libvirt-bin debootstrap

* instalar LXC
apt-get install lxc

* agregar los cgroups al fstab:
cgroup  /sys/fs/cgroup  cgroup  defaults  0   0

* y montar:
mount -a

* verificar que ha sido creado cgroup:

ls /sys/fs/cgroup/
blkio.io_merged		blkio.reset_stats      cgroup.event_control  cpuset.cpus		     cpuset.memory_spread_page	      devices.allow	 tasks
blkio.io_queued		blkio.sectors	       cgroup.procs	     cpuset.mem_exclusive	     cpuset.memory_spread_slab	      devices.deny
blkio.io_service_bytes	blkio.time	       cpuacct.stat	     cpuset.mem_hardwall	     cpuset.mems		      devices.list
blkio.io_serviced	blkio.weight	       cpuacct.usage	     cpuset.memory_migrate	     cpuset.sched_load_balance	      net_cls.classid
blkio.io_service_time	blkio.weight_device    cpuacct.usage_percpu  cpuset.memory_pressure	     cpuset.sched_relax_domain_level  notify_on_release
blkio.io_wait_time	cgroup.clone_children  cpuset.cpu_exclusive  cpuset.memory_pressure_enabled  cpu.shares			      release_agent
i

* agregar a default/grub:
cgroup_enable=memory swapaccount=1

* actualizar grub
update-grub

* reiniciar
reboot

== Particion para LXC ==

* formatear óptimamente con LXC
mkfs.xfs  -l internal,lazy-count=1,size=256m -b size=4096 -d sunit=8,swidth=16 -f -L lxc /dev/vgpheno/lxc

* Y montar en la partición dónde irán los contenedores LXC:
/dev/vgpheno/lxc /srv/lxc xfs rw,noatime,nodiratime,attr2,nobarrier,logbufs=8,sunit=8,swidth=16,logbsize=256k,largeio,inode64,swalloc,noquota,allocsize=16M 0 0


== Configuracion ==

* verificar que LXC podría funcionar en este equipo:

lxc-checkconfig 

Kernel config /proc/config.gz not found, looking in other places...
Found kernel config file /boot/config-3.2.0-4-amd64
--- Namespaces ---
Namespaces: enabled
Utsname namespace: enabled
Ipc namespace: enabled
Pid namespace: enabled
User namespace: enabled
Network namespace: enabled
Multiple /dev/pts instances: enabled

--- Control groups ---
Cgroup: enabled
Cgroup clone_children flag: enabled
Cgroup device: enabled
Cgroup sched: enabled
Cgroup cpu account: enabled
Cgroup memory controller: enabled
Cgroup cpuset: enabled

--- Misc ---
Veth pair device: enabled
Macvlan: enabled
Vlan: enabled
File capabilities: enabled

Note : Before booting a new kernel, you can check its configuration
usage : CONFIG=/path/to/config /usr/bin/lxc-checkconfig

* Verificar que todos los requerimientos (como memory o cpuset), han sido montados:

grep cgroup /proc/self/mounts
cgroup /sys/fs/cgroup cgroup rw,relatime,perf_event,blkio,net_cls,freezer,devices,memory,cpuacct,cpu,cpuset 0 0

Instalacion de dependencias (Debian)
=====

* instalar las dependencias

apt-get install debootstrap lsb-release wget rsync curl yum rpm

Listo!, ya puedes hacer uso de los LXC-tools.
