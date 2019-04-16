#!/bin/bash

IFACE_FLAG=0

if [[ "$EUID" != "0" ]];
then
    echo "This script must be run as root" 1>&2
	exit
fi

#Get ethernet interface
get_interface()
{
INTERFACE=`ip link show | awk -F: '$0 !~ "lo|vir|vbox|wl|tun|^[^0-9]" {print $2;exit}'| sed 's/ //'`
echo  "Interface = " ${INTERFACE}
}

change_originalmac()
{
	ORIGINALMAC=`ip addr show ${INTERFACE} | awk 'NR==2{print $2}' `
	echo 'Original Mac =  ' ${ORIGINALMAC}
	VENDORBYTES=`echo ${ORIGINALMAC}| cut -f 1-3 -d ":" `
	NONVENDORBYTES=`echo ${ORIGINALMAC} | cut -f 4-6 -d ":" | rev `
	NEWMAC="${VENDORBYTES}:${NONVENDORBYTES}"
	echo 'New Mac =	' ${NEWMAC}
}

#check if there's a mismatch in the interfaces file
check_interfaces_file()
{
IFACE_EXISTS="$(grep -cw ${INTERFACE} /etc/network/interfaces)"
if [[ ${IFACE_EXISTS} -ne 2 ]] || [[ ${IFACE_EXISTS} -ne 3 ]];
then
	IFACE_FLAG=1
	set_newmac
else
	set_newmac
fi
}

set_newmac()
{
	echo "Set new Mac Address permanently"
	cat << EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).
# The loopback network interface
auto lo
iface lo inet loopback
auto ${INTERFACE}
#Your static network configuration
iface ${INTERFACE} inet dhcp
	hwaddress ether ${NEWMAC}
EOF
	if [[ ${IFACE_FLAG} -eq 1 ]];
	then
		systemctl restart networking
		ip link set dev ${INTERFACE} up
	else
		systemctl restart networking
		ip link set dev ${INTERFACE} down
		ip link set dev ${INTERFACE} up
	fi
}
update_address_table()
{
echo ${ORIGINALMAC} ',' ${NEWMAC} | ssh user_with_cert@dhcp_server_ip -T "cat >> ~/linux_hosts.txt"
}

get_interface
change_originalmac
check_interfaces_file
update_address_table
