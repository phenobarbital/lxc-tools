#!/bin/bash
##
#  /usr/lib/lxc-tools/build.sh
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

if [ "$DIR" = "auto" ]; then
	DIR=`get_lxcpath`
fi

if [ "$LVM" = "auto" ]; then
	LVM=`get_lvm`
  if [ -z "$LVM" ]; then
    echo "error: cannot configure lvm, missing active volume group"
    exit 1
  fi
fi

## info about distribution, repository and suite
if [ "$DIST" = "auto" ]; then
	DIST=`get_distribution`
fi
if [ "$SUITE" = "auto" ]; then
	SUITE=`get_suite`
fi
if [ "$MIRROR" = "auto" ]; then
	MIRROR=`get_suite_repository`
fi

### auto-configure variables
DOMAIN=`get_domain`
LXC=`get_lxcversion`
ARCH=`get_arch`
BRIDGE=`get_default_bridge`
GATEWAY=$(get_ip $BRIDGE)
NETMASK=$(get_netmask $BRIDGE)
NETWORK=$(get_network $GATEWAY $NETMASK)

