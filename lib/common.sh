#!/bin/bash
##
#  /usr/lib/lxc-tools/common.sh
#
#  Common shell functions which may be used by any lxc template
#
##

VERSION='0.2'

function get_version() 
{
	echo "LXC-tools version $VERSION";
}

# basic functions
#

#  If we're running verbosely show a message, otherwise swallow it.
#
function message()
{
    message="$*"

    if [ ! -z "$VERBOSE" ]; then
        echo $message >&2;
    fi
}

function info()
{
	message="$*"

    if [ ! -z "$VERBOSE" ]; then
        echo -e $message;
    fi
}

function error()
{
	message="$*"
	echo -e $message >&2;
}

optarg_check() 
{
    if [ -z "$2" ]; then
        usage_err "option '$1' requires an argument"
    fi
}

function templatedir()
{
		if [ -d "/usr/share/lxc-tools/templates.d" ]; then
			TEMPLATEDIR="/usr/share/lxc-tools/templates.d"
		else
			TEMPLATEDIR="./templates.d"
		fi
}

function roledir()
{
		if [ -d "/usr/share/lxc-tools/role.d" ]; then
			ROLEDIR="/usr/share/lxc-tools/role.d"
		else
			ROLEDIR="./role.d"
		fi
}

function get_lxcpath() 
{
	if [ -e /etc/lxc/lxc.conf ]; then
		# using config dir from lxc
		grep "[ \t]*lxcpath[ \t]*=" /etc/lxc/lxc.conf | awk -F= '{ print $2 }'
	else
		# using /etc/default/lxc
		grep "[ \t]*LXC_DIRECTORY[ \t]*=" /etc/default/lxc | awk -F= '{ print $2 }' | sed 's/"//g'
	fi
}

function get_domain() 
{
	_DOMAIN_=`hostname -d`
	if [ -z "$_DOMAIN_" ]; then
				echo -n "Domain not defined, please define a domain [ex: example.com] "
				read _DOMAIN_
				if [ ! -z "$_DOMAIN_" ]; then
					echo $_DOMAIN_
				else
					DOMAIN="example.com"
				fi
	else
			#usamos el dominio configurado del host
			echo $_DOMAIN_
	fi
}

# return distribution based on lsb-release
function get_distribution() 
{
	if [ -z $(which lsb_release) ]; then
		echo "lxc-tools error: lsb-release is required"
		exit 1
	fi
	lsb_release -s -i
}

# get codename (ex: wheezy)
function get_suite() 
{
	if [ -z $(which lsb_release) ]; then
		echo "lxc-tools error: lsb-release is required"
		exit 1
	fi
	lsb_release -s -c
}

function get_lxcversion() 
{
	if [ `get_distribution` = "Debian" ]; then
		dpkg-query -W -f='${Version}' lxc
		# TODO: per distribution lxc version
	fi
}

# get architecture
function get_arch() 
{
	if [ -z $(which lsb_release) ]; then
		echo "lxc-tools error: lsb-release is required"
		exit 1
	fi
	if [ `get_distribution` = "Debian" ]; then
		dpkg --print-architecture
	fi
}

# get repository name
function get_suite_repository() 
{
	dist=`get_distribution`
	if [ "$dist" = "Debian" ]; then
		suite=`get_suite`
		grep -r "^deb http*" /etc/apt | grep "$suite main" | head -n1 | cut -d ' ' -f2
	else
		echo 'http://http.debian.net/debian/'
	fi
}

# obtener el nombre del grupo de volumen LVM
function get_lvm() 
{
	# determinar el nombre del primer volumen lógico
    vgs | tail -n1 | awk '{print $1}'
}

function get_default_bridge() 
{
	if [ "$BRIDGE" = "auto" ]; then
		# obtenemos la lista de interfaces activas
		get_bridge
	elif [ -z "$BRIDGE" ]; then
			echo "error: cannot configure network, missing configure bridge"
			exit 1
	elif [ -z `cat /proc/net/dev | grep $BRIDGE` ]; then
				echo "lxc-tools error: interface $BRIDGE not configured"
	else
		echo $BRIDGE
	fi
}

function cgroup_enabled() 
{
		cgroup=`grep cgroup /proc/self/mounts`
		if [ -z "$cgroup" ]; then
			echo "lxc-tools error: cgroups are not configured"
			exit 1
		fi
		if [ -z `grep cgroup /proc/self/mounts | grep memory` ]; then
			echo "lxc-tools error: cgroup memory not enabled, please add cgroup_enable=memory to grub boot"
			exit 1
		fi
		return 0
}

# install a package into chroot
function install_package()
{
	# get distribution
	dist=`get_distribution`
	if [ "$dist" = "Debian" ]; then
		message "installing Debian package $@"
		#
		# Install the packages
		#
		DEBIAN_FRONTEND=noninteractive chroot $ROOTFS /usr/bin/apt-get --option Dpkg::Options::="--force-overwrite" --option Dpkg::Options::="--force-confold" --yes --force-yes install "$@"
	fi
	# TODO: other distro versions
}
