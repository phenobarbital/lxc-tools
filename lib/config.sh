#!/bin/bash
##
#  /usr/lib/lxc-tools/config.sh
#
#  Fill all basic variable automagically
#
##

#
#  library for network configuration
#
if [ -e /usr/lib/lxc-tools/netinfo.sh ]; then
    . /usr/lib/lxc-tools/netinfo.sh
else
    . ./lib/netinfo.sh
fi

# verify if cgroup is enabled
cgroup=`cat /proc/self/mounts | grep cgroup`
if [ -z "$cgroup" ]; then
	echo -e "lxc-tools error: cgroups are not configured"
	exit 1
	if [ -z `cat /proc/self/mounts | grep cgroup | grep memory` ]; then
		echo -e "lxc-tools error: cgroup memory not enabled, please add cgroup_enable=memory to grub boot"
		exit 1
	fi
fi
		
# Make sure we have a log directory
if [ ! -d "$LOGDIR" ]; then
	if [ "$VERBOSE" == 'true' ]; then
		echo "creating log directory $LOGDIR"
	fi
	mkdir -p "$LOGDIR"
fi

# configure backend
if [ -z "$BACKEND_METHOD" ]; then
	# if not backend_method defined, dir is by default
	BACKEND_METHOD='dir'
fi

# defined DIR variable
# directory method
if [ "$DIR" = "auto" ]; then
	DIR=`get_lxcpath`
elif [ -z "$DIR" ]; then
	DIR=`get_lxcpath`
fi
if [ ! -d "$DIR" ]; then
	error "directory $DIR does not exists, aborted"
	exit 1
fi

if [ "$BACKEND_METHOD" = 'lvm' ]; then
	# get volume group
	if [ "$LVM" = "auto" ]; then
		LVM=`get_lvm`
	if [ -z "$LVM" ]; then
		echo "error: cannot configure LVM, missing active volume group"
		exit 1
	fi
	else
		# verify lvm group
		if [ -z `vgs | tail -n1 | grep $LVM` ]; then
			error "error: LVM group $LVM does not exist, or not configured"
			exit 1
		fi
	fi
	# verify filesystem
    grep -q "\<$FS\>" /proc/filesystems
    if [ $? -ne 0 ]; then
        error "error: $FS is not listed in /proc/filesystems" >&2
        exit 1
    fi
#elif [ "$BACKEND_METHOD" = 'btrfs' ]; then
#TODO
fi

# get network information
get_network_info() {
	debug "Using network type $NET_TYPE"
	if [ "$DHCP" = 'n' ]; then
		#use static ip
		if [ -z "$IP" ]; then
			echo -n "IP Address for container [ex: 192.168.1.x]: "
			read _IP_
			if [ ! -z "$_IP_" ]; then
				IP=$_IP_
			else
				error "error: missing IP Address"
				exit 1
			fi
		fi
		# TODO: validate IP Address
        # use fixed IP
        NET="$IP/$SUBNET"
    else
		# use DHCP
		NET="0.0.0.0/$SUBNET"
		IP="DHCP"
	fi
    # get mac-address
	if [ -f /usr/lib/lxc-tools/macgen.py ]; then
		MACADDR=`python /usr/lib/lxc-tools/macgen.py`
	else
		MACADDR=`python ./lib/macgen.py`
	fi
	# MACADDR=`openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'`
	# get network type
	case "$NET_TYPE" in
	'veth')
NET_OPTIONS=$(cat <<EOF
lxc.network.link                        = $BRIDGE
lxc.network.hwaddr                      = $MACADDR
lxc.network.ipv4                        = $NET
EOF
)
;;
	'macvlan')
NET_OPTIONS=$(cat <<EOF
lxc.network.link                        = $IFACE
lxc.network.hwaddr                      = $MACADDR
lxc.network.ipv4                        = $NET
EOF
)
;;
	'vlan')
NET_OPTIONS=$(cat <<EOF
lxc.network.link                        = $IFACE
lxc.network.vlan.id                     = $VLAN_ID
lxc.network.hwaddr                      = $MACADDR
lxc.network.ipv4                        = $NET
EOF
)
;;
	'empty')
		NET_OPTIONS='';;
	'*')
		error "invalid network configuration"
		exit 1;;
	esac
}
	
if [ "$NET_TYPE" = "veth" ]; then
	# get default bridge
	if [ "$BRIDGE" = "auto" ]; then
		# obtenemos la lista de interfaces activas
		BRIDGE=`get_bridge`
	elif [ -z "$BRIDGE" ]; then
			error "cannot configure network, missing a configured bridge"
			exit 1
	elif [ -z `cat /proc/net/dev | grep $BRIDGE` ]; then
			error "unconfigured interface $BRIDGE"
			exit 1
	fi
	if [ ! -z "$BRIDGE" ]; then
		# all network info
		GATEWAY=$(get_ip $BRIDGE)
		NETMASK=$(get_netmask $BRIDGE)
		NETWORK=$(get_network $GATEWAY $NETMASK)
		SUBNET=$(get_subnet $BRIDGE)
	else
		error "error: cannot configure network, missing a configured bridge"
		exit 1
	fi
elif [ "$NET_TYPE" = "vlan" ] || [ "$NET_TYPE" = "macvlan" ]; then
	if [ -z "$IFACE" ]; then
		# si no esta configurada la interface
		error "cannot configure network, require --iface option"
		exit 1
	fi
	# all network info
	if test GATEWAY=$(get_ip $IFACE); then
		error "unconfigured interface $IFACE"
		exit 1
	else
		NETMASK=$(get_netmask $IFACE)
		NETWORK=$(get_network $GATEWAY $NETMASK)
		SUBNET=$(get_subnet $IFACE)	
	fi
elif [ "$NET_TYPE" = "phys" ]; then
	if [ -z "$IFACE" ]; then
		# si no esta configurada la interface
		error "cannot configure physical network, interface required (use --iface option)"
		exit 1
	fi
elif [ "$NET_TYPE" = "empty" ]; then
	# no network available
	NETWORK='0.0.0.0'
fi

# get distribution only if $DIST is not defined
if [ -z "$DIST" ] || [ "$DIST" = 'auto' ]; then
	DIST=`get_distribution`
	if [ "$SUITE" = "auto" ]; then
		SUITE=`get_suite`
	fi
	if [ "$MIRROR" = "auto" ]; then
		set_suite_repository
	fi
fi

# define default size, if $SIZE is not defined
if [ -z "$SIZE" ] || [ "$SIZE" = 'auto' ]; then
	SIZE=$DEFAULT_SIZE
fi

### auto-configure variables
LXC=`get_lxcversion`
ARCH=`get_arch`
