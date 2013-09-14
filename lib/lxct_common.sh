#!/bin/bash
##
#  /usr/lib/lxc-tools/lxct_common.sh
#
#  Common shell functions which may be used by any lxc template
#
##

VERSION='0.5'

export NORMAL='\033[0m'
export RED='\033[1;31m'
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export WHITE='\033[1;37m'
export BLUE='\033[1;34m'

#
#  library for logging facility
#
if [ -e /usr/lib/lxc-tools/lxct_logging.sh ]; then
    . /usr/lib/lxc-tools/lxct_logging.sh
else
    . ./lib/lxct_logging.sh
fi

get_version() 
{
	echo "LXC-tools version $VERSION";
}

# basic functions
#

#  If we're running verbosely show a message, otherwise swallow it.
#
message()
{
    message="$*"
    echo -e $message >&2;
    logMessage $message
}

info()
{
	message="$*"
    if [ "$VERBOSE" == "true" ]; then
		printf "$GREEN"
		printf "%s\n"  "$message" >&2;
		tput sgr0 # Reset to normal.
		echo -e `printf "$NORMAL"`
    fi
    logMessage $message
}

warning()
{
	message="$*"
    if [ "$VERBOSE" == "true" ]; then
		printf "$YELLOW"
		printf "%s\n"  "$message" >&2;
		tput sgr0 # Reset to normal.
		printf "$NORMAL"
    fi
    logMessage "WARN: $message"
}

debug()
{
	message="$*"
	if [ "$VERBOSE" == "true" ]; then
    # if [ ! -z "$VERBOSE" ] || [ "$VERBOSE" == "true" ]; then
		printf "$BLUE"
		printf "%s\n"  "$message" >&2;
		tput sgr0 # Reset to normal.
		printf "$NORMAL"
    fi
    logMessage "DEBUG: $message"
}

error()
{
	message="$*"
	scriptname=$(basename $0)
	printf "$RED"
	printf "%s\n"  "$scriptname $message" >&2;
	tput sgr0 # Reset to normal.
	printf "$NORMAL"
	logMessage "ERROR:  $message"
	return 1
}

usage_err()
{
	error "$*"
	exit 1
}

optarg_check() 
{
    if [ -z "$2" ]; then
        usage_err "option '$1' requires an argument"
    fi
}

templatedir()
{
		if [ -d "/usr/share/lxc-tools/templates.d" ]; then
			TEMPLATEDIR="/usr/share/lxc-tools/templates.d"
		else
			TEMPLATEDIR="./templates.d"
		fi
}

roledir()
{
		if [ -d "/usr/share/lxc-tools/role.d" ]; then
			ROLEDIR="/usr/share/lxc-tools/role.d"
		else
			ROLEDIR="./role.d"
		fi
}

get_lxcpath() 
{
	if [ -e /etc/lxc/lxc.conf ]; then
		# using config dir from lxc
		grep "[ \t]*lxcpath[ \t]*=" /etc/lxc/lxc.conf | awk -F= '{ print $2 }'
	else
		# using /etc/default/lxc
		grep "[ \t]*LXC_DIRECTORY[ \t]*=" /etc/default/lxc | awk -F= '{ print $2 }' | sed 's/"//g'
	fi
}

# get hostname
function get_hostname() {
        if [ -z "$NAME" ]; then
                echo -n "name of container? [ex: `hostname --short`] "
                read _HOSTNAME_
                if [ ! -z "$_HOSTNAME_" ]; then
                    NAME=$_HOSTNAME_
                elif [ -z "$NAME" ]; then
                    error "error : missing container name, use -n|--name option"
                    exit 1
                fi
        fi
        HOSTNAME=$NAME.$DOMAIN
}

define_domain()
{
	echo -n 'Please define a Domain name [ex: example.com]: '
	read _DOMAIN_
	if [ -z "$_DOMAIN_" ]; then
		message "error: Domain not defined"
		return 1
	else
		DOMAIN=$_DOMAIN_
	fi
}

get_domain() 
{
	if [ -z "$DOMAIN" ] || [ "$DOMAIN" = "auto" ]; then
		# auto-configure domain:
		_DOMAIN_=`hostname -d`
		if [ -z "$_DOMAIN_" ]; then
			define_domain
		else
			DOMAIN=$_DOMAIN_
		fi
	fi
}

# return host distribution based on lsb-release
get_distribution() 
{
	if [ -z $(which lsb_release) ]; then
		echo "lxc-tools error: lsb-release is required"
		exit 1
	fi
	lsb_release -s -i
}

# get codename (ex: wheezy)
get_suite() 
{
	if [ -z $(which lsb_release) ]; then
		echo "lxc-tools error: lsb-release is required"
		exit 1
	fi
	lsb_release -s -c
}

# get lxc version
# TODO: get version for Distribution
get_lxcversion() 
{
	if [ `get_distribution` = "Debian" ]; then
		dpkg-query -W -f='${Version}' lxc
		# TODO: per distribution lxc version
	fi
}

# get architecture
get_arch() 
{
	if [[ -z "$ARCH" || "$ARCH" == 'auto' || -n "$ARCH" ]]; then
		ARCH=`uname -m`
	fi
	echo $ARCH
}

# get repository name
# TODO case ... esac for dist versions
set_suite_repository() 
{
	if [[ -z "$MIRROR" || "$MIRROR" = "auto" || -n "$MIRROR" ]]; then
		# get repository information
		case "$DIST" in
			"debian"|"Debian"|"DEBIAN")
			if [[ -z "$SUITE" || "$SUITE" = "auto" || -n "$SUITE" ]]; then
				suite=`get_suite`
				_suite=`grep -r "^deb http*" /etc/apt | grep "debian" | grep "$suite main" | head -n1 | cut -d ' ' -f2`
				if [ -z "$_suite" ]; then
					MIRROR='http://http.debian.net/debian/'
				else
					MIRROR=$_suite
				fi
			fi
			;;
		esac
	fi
}

# obtener el nombre del grupo de volumen LVM
get_lvm() 
{
	# determinar el nombre del primer volumen lógico
    vgs | tail -n1 | awk '{print $1}'
}

# install a package into chroot
install_package()
{
	# get distribution if $DIST its not defined
	if [ -z "$DIST" ]; then
		DIST=`get_distribution`
	fi
	case "$DIST" in
		"debian"|"Debian"|"DEBIAN")
		"ubuntu"|"Ubuntu"|"UBUNTU")
				message "installing Debian package $@"
				#
				# Install the packages
				#
				DEBIAN_FRONTEND=noninteractive chroot $ROOTFS /usr/bin/apt-get --option Dpkg::Options::="--force-overwrite" --option Dpkg::Options::="--force-confold" --yes --force-yes install "$@"
				;;			
		"canaima"|"Canaima"|"CANAIMA")
				message "installing Canaima package $@"
				#
				# Install the packages
				#
				DEBIAN_FRONTEND=noninteractive chroot $ROOTFS /usr/bin/apt-get --option Dpkg::Options::="--force-overwrite" --option Dpkg::Options::="--force-confold" --yes --force-yes install "$@"
				;;				
		"centos"|"Centos"|"CENTOS"|"CentOS")
				message "installing Centos package $@"
				/usr/bin/yum -y install "$@"
				;;
		"fedora"|"Fedora"|"FEDORA")
				message "installing Fedora package $@"
				/usr/bin/yum -y install "$@"
				;;						
		*)
				error "unknown package manager for $DIST"
				return 1
				;;
	esac
}

remove_package()
{
	# get distribution if $DIST its not defined
	if [ -z "$DIST" ]; then
		DIST=`get_distribution`
	fi
	case "$DIST" in
		"debian"|"Debian"|"DEBIAN")
		"ubuntu"|"Ubuntu"|"UBUNTU")
				message "remove Debian package $@"
				#
				# Install the packages
				#
				DEBIAN_FRONTEND=noninteractive chroot $ROOTFS /usr/bin/apt-get remove --yes --purge "$@"
				;;
		"canaima"|"Canaima"|"CANAIMA")
				message "remove Canaima package $@"
				#
				# Install the packages
				#
				DEBIAN_FRONTEND=noninteractive chroot $ROOTFS /usr/bin/apt-get remove --yes --purge "$@"
				;;				
		"centos"|"Centos"|"CENTOS"|"CentOS")
				message "remove Centos package $@"
				/usr/bin/yum -y erase "$@"
				;;
		"fedora"|"Fedora"|"FEDORA")
				message "remove Fedora package $@"
				/usr/bin/yum -y erase "$@"
				;;							
		*)
				error "unknown package manager for $DIST"
				return 1
				;;
	esac
	# TODO: other distro versions
}

show_summary()
{

SUMMARY=$(cat << _MSG
 ---------- [ Summary options for $NAME ] ---------------------
 
  Config Dir :	................... $CONFIG
  RootFS : ........................ $ROOTFS
  Distribution : .................. $DIST
  Arch : .......................... $ARCH
  Domain : ........................ $DOMAIN
  Network Mode : .................. $NET_TYPE
  Install Mode : .................. $BACKEND_METHOD
  Gateway : ....................... $GATEWAY
  Netmask : ....................... $NETMASK
  Network : ....................... $NETWORK
  Mac Address : ................... $MACADDR
  Network : ....................... $NET
 
 ---------------------------------------------------------------
_MSG
)

echo "$SUMMARY"
logData "$SUMMARY"
}

install_summary()
{
SUMMARY=$(cat << _MSG

Installation Summary
---------------------
Hostname        :  $HOSTNAME
Distribution    :  $DIST
Network Mode    :  $NET_TYPE
IP-Address      :  $IP
Mac Address     :  $MACADDR

_MSG
)
echo "$SUMMARY"
logData "$SUMMARY"
}
