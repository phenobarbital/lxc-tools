#!/bin/bash
# ================================================================================
# LXC-tools: Appliance and LXC container builder for Debian GNU/Linux (and derivatives)
#
# Copyright © 2010 Jesús Lara Giménez (phenobarbital) <jesuslara@devel.com.ve>>
# Version: 0.2    
#
#    Developed by Jesus Lara (phenobarbital) <jesuslara@phenobarbital.info>
#    https://github.com/phenobarbital/mandarinalinux
#    
#    This script is based on the lxc-debian example script that ships with lxc.
#    Copyright (C) 2010 Nigel McNie
#
#    License: GNU GPL version 3  <http://gnu.org/licenses/gpl.html>.
#    This is free software: you are free to change and redistribute it.
#    There is NO WARRANTY, to the extent permitted by law.
# ================================================================================

###
# netinfo
# get network information
##

# get firt available bridge
function get_bridge() {
	# obtenemos la lista de interfaces activas
	for i in `cat /proc/net/dev | grep ':' | cut -d ':' -f 1`; do
		if [ -z `brctl show $i | grep $1 | head -n1 | awk '{print $1}' | grep "Operation not supported"` ]; then
			brctl show | grep "$i" | awk '{print $1}'
			return 0
		fi
	done
	return 1
}

# get ip from interface
function get_ip() {
	# get ip info
	IP=`ip addr show $1 | grep "[\t]*inet " | head -n1 | awk '{print $2}' | cut -d'/' -f1`
	if [ -z "$IP" ]; then
		echo "ip error: interface not configured"
		exit 1
	else
		echo $IP
	fi
}

# get netmask from IP
function get_netmask() {
	ifconfig $1 | sed -rn '2s/ .*:(.*)$/\1/p'
}

# get network from ip and netmask
function get_network() {
	IFS=. read -r i1 i2 i3 i4 <<< "$1"
	IFS=. read -r m1 m2 m3 m4 <<< "$2"
	printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$(($i2 & m2))" "$((i3 & m3))" "$((i4 & m4))"
}

# get broadcast from interface
function get_broadcast() {
	# get ip info
	ip addr show $1 | grep "[\t]*inet " | head -n1 | egrep -o 'brd (.*) scope' | awk '{print $2}'
}

# get subnet octect
function mask2cidr() {
    nbits=0
    IFS=.
    for dec in $1 ; do
        case $dec in
            255) let nbits+=8;;
            254) let nbits+=7;;
            252) let nbits+=6;;
            248) let nbits+=5;;
            240) let nbits+=4;;
            224) let nbits+=3;;
            192) let nbits+=2;;
            128) let nbits+=1;;
            0);;
            *) echo "Error: $dec is not recognised"; exit 1
        esac
    done
    echo "$nbits"
}

function get_subnet() {
	MASK=`get_netmask`
	echo $(mask2cidr $MASK)
}
