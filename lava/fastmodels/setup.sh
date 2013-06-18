#!/bin/bash
#Copyright ARM Ltd 2010
#Copyright 2012 Linaro Limited

# errors handling function
error()
{
    echo -e "$1"
    exit 1
}

print()
{
    echo -e "$1"
}

print_no_newline()
{
    echo -en "$1"
}


write_file()
{
  case "$2" in
    "append")
       echo "$3">>"$1"
       ;;
     "new")
       echo "$3">"$1"
       ;;
     *)
       print "write_file: Wrong command"
       ;;
  esac
}

# Deterine where we are running.
dir=`dirname $0`

print "ARM FastModels configuration script.\n"

# check if the script is running as root
if [ $(whoami) != "root" ]
then
    error "ERROR: Please run this script as root."
fi

# setup path
PATH=.:/sbin:/usr/sbin:/bin:/usr/bin

if ! type tapctrl > /dev/null 2>&1; then
    error "ERROR: Please install the tapctrl command"
fi

if ! type brctl > /dev/null 2>&1; then
    error "ERROR: Please install the bridge-utils package for brctl command"
fi

# set default tap device name prefix
print "Use default TAP device prefix: armv8_"
tapPrefix="armv8_"

print "Will create TAP devices under the user of www-data"
user="www-data"

print "Will create following interface: ${tapPrefix}01 ${tapPrefix}02"
INTERFACES="01 02"

print "The TAP devices need to be bridged to a network adapter to allow access to
the network. Here use the defaut adapter(eth0) to bridge"
nic=eth0

# Ask root to specify a name for the network bridge
print "Use the armbr0 as the default network bridge"
bridge=armbr0

# Ask root to specify where they want the init script written
print "The init script will be saved here: /etc/init.d/FMNetwork"
script=/etc/init.d/FMNetwork

# Nothing is done to the system before this point; apart from installing
# the brctl utility if not present.

# Give permission to normal users
print "Installing"
print_no_newline "- Changing '/dev/net/tun' permissions... "
chmod 666 /dev/net/tun
file=`grep \"tun\" /etc/udev/rules.d/* -l`

count=0
if [ x$file != x ]
then
    count=`grep "\"tun\"" $file | grep 666 -c`
fi

if [ x$file != x ] && [ $count == 0  ]
then
    sed '/KERNEL==\"tun\"/ s/\(MODE=\)\".*\"/\1\"0666\"/' -i $file
fi
print "done."

default_gw=`route | grep ^default | awk '{print $2}'`
host_ip=`ifconfig $nic | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`

# take down ethx
print_no_newline "- Creating bridge '$bridge'... "
ip addr flush "$nic" >/dev/null 2>&1
ifconfig "$nic" 0.0.0.0 promisc down >/dev/null 2>&1

# wait for nic to go down <- critical to add this sleep
sleep 3

# create bridge
brctl addbr $bridge >/dev/null 2>&1

bridge_mac=`ifconfig $bridge | grep $bridge | awk '{print $5}'`
brctl addif $bridge "$nic" >/dev/null 2>&1
print "done."

# create tap devices and add them into the bridge
for interface in $INTERFACES
do
    interface_name="${tapPrefix}${interface}"
    print_no_newline "- Creating TAP device for '$user'... "
    tapctrl -n ${interface_name} -a create -o $user -t tap >/dev/null 2>&1
    ifconfig ${interface_name} 0.0.0.0 promisc up >/dev/null 2>&1
    brctl addif $bridge ${interface_name} >/dev/null 2>&1
    print "done."
done

print_no_newline "- Configuring IP setting... "
# reassign MAC address for br0 since it could conflict with host NIC
ifconfig $bridge hw ether $bridge_mac 0.0.0.0 promisc
ip link set $nic up
ip link set $bridge up
# renew the DHCP address
pid=`ps aux | grep "dhclient $bridge" | grep -v grep | awk '{print $2}'` >/dev/null 2>&1
kill -9 $pid >/dev/null 2>&1
# wait process to finish
sleep 1s
dhclient $bridge >/dev/null 2>&1
route add default gw $default_gw $bridge
ifconfig $nic $host_ip
sleep 2
route del default gw $default_gw $nic >/dev/null 2>&1
route del $default_gw $nic >/dev/null 2>&1
print "done."

scriptname=`basename $script`
print_no_newline "- Generating init script... "

if [ -e "$script" ]
  then
    write_file "$script" "new" "#! /bin/bash"
else
    touch "$script"
    write_file "$script" "append" "#! /bin/bash"
fi

lsb_header="$dir/lsb.header"
cat  >>$script <<__EOF__
### BEGIN INIT INFO
# Provides: ARM Ltd
# Required-Start: \$local_fs \$network \$syslog
# Should-Start:
# Required-Stop: \$local_fs \$network \$syslog
# Should-Stop:
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short-Description: FM Network Setup
# Description: FM Network Setup
#              Create TAP deivces and network bridge for Fast Models
#              See http://www.arm.com/products/tools/fast-models.php
#              for more information.
### END INIT INFO

# This is an example of a Linux LSB conforming init script.
# See http://refspecs.freestandards.org/ for more information on LSB.

# \$FastModels\$

__EOF__

write_file "$script" "append" "# source function library"
write_file "$script" "append" "if [ -e /etc/rc.d/init.d/functions ];then"
write_file "$script" "append" "    source /etc/rc.d/init.d/functions"
write_file "$script" "append" "elif [ -e /lib/lsb/init-functions ];then"
write_file "$script" "append" "    source /lib/lsb/init-functions"
write_file "$script" "append" "else"
write_file "$script" "append" "    echo 'Unable to find lsb functions'"
write_file "$script" "append" "fi"

write_file "$script" "append" "PATH=.:/sbin:/usr/sbin:/bin:/usr/bin"
write_file "$script" "append" "user=\"$user\""
write_file "$script" "append" "INTERFACES=\"$INTERFACES\""
write_file "$script" "append" "NIC=$nic"
write_file "$script" "append" "PREFIX=$tapPrefix"
write_file "$script" "append" "BRIDGE=$bridge"

write_file "$script" "append" "start()"
write_file "$script" "append" "{"
write_file "$script" "append" "    PID=\`ps aux | grep dhclient | grep armbr0 | grep -v grep | awk '{print \$2}'\`"
write_file "$script" "append" "    DEFAULT_GW=\`route | grep ^default | awk '{print \$2}'\`"
write_file "$script" "append" "    HOST_IP=\`ifconfig \$NIC | grep 'inet addr:' | cut -d: -f2 | awk '{print \$1}'\`"
write_file "$script" "append" ""
write_file "$script" "append" "    if [ x\$PID != x ]; then"
write_file "$script" "append" "        echo \"TAP Bridge \$BRIDGE already exist and $scriptname is running.\""
write_file "$script" "append" "        exit 1"
write_file "$script" "append" "    fi"
write_file "$script" "append" ""
write_file "$script" "append" "    # take down ethx"
write_file "$script" "append" "    ip addr flush \$NIC"
write_file "$script" "append" "    ifconfig \$NIC 0.0.0.0 promisc down"
write_file "$script" "append" "    sleep 3"
write_file "$script" "append" "    # create bridge"
write_file "$script" "append" "    brctl addbr \$BRIDGE"
write_file "$script" "append" "    BRIDGE_MAC=\`ifconfig \$BRIDGE | grep \$BRIDGE | awk '{print \$5}'\`"
write_file "$script" "append" "    brctl addif \$BRIDGE \$NIC"
write_file "$script" "append" "    # create tap devices and add them into the bridge"
write_file "$script" "append" "    for interface in \$INTERFACES"
write_file "$script" "append" "    do"
write_file "$script" "append" "       interface_name=\$PREFIX\$interface"
write_file "$script" "append" "       tapctrl -n \${interface_name} -a create -o \$user -t tap"
write_file "$script" "append" "       ifconfig \${interface_name} 0.0.0.0 promisc up"
write_file "$script" "append" "       brctl addif \$BRIDGE \${interface_name}"
write_file "$script" "append" "    done"
write_file "$script" "append" "    ifconfig \$NIC up"
write_file "$script" "append" "    ifconfig \$BRIDGE hw ether \$BRIDGE_MAC 0.0.0.0 promisc"
write_file "$script" "append" "    ip link set \$BRIDGE up"
write_file "$script" "append" "    # wait process to finish"
write_file "$script" "append" "    sleep 1s"
write_file "$script" "append" "    dhclient \$BRIDGE"
write_file "$script" "append" "    route add default gw \$DEFAULT_GW \$BRIDGE"
write_file "$script" "append" "    ifconfig \$NIC \$HOST_IP"
write_file "$script" "append" "    sleep 2"
write_file "$script" "append" "    route del default gw \$DEFAULT_GW \$NIC >/dev/null 2>&1"
write_file "$script" "append" "    route del \$DEFAULT_GW \$NIC >/dev/null 2>&1"
write_file "$script" "append" "    ip addr show 2>&1 > /var/log/fm_bridge_create.log"
write_file "$script" "append" "    sleep 3"
write_file "$script" "append" "}"

write_file "$script" "append" "stop()"
write_file "$script" "append" "{"
write_file "$script" "append" "   PID=\`ps aux | grep dhclient | grep armbr0 | grep -v grep | awk '{print \$2}'\`"
write_file "$script" "append" "   HOST_IP=\`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print \$1}'\`"
write_file "$script" "append" "   DEFAULT_GW=\`route | grep ^default | awk '{print \$2}'\`"
write_file "$script" "append" ""
write_file "$script" "append" "    if [ x\$PID == x ]; then"
write_file "$script" "append" "        echo \"TAP Bridge \$BRIDGE does not exist and no $scriptname to stop.\""
write_file "$script" "append" "        exit 1"
write_file "$script" "append" "    fi"
write_file "$script" "append" ""
write_file "$script" "append" "    # take down the bridge"
write_file "$script" "append" "    kill -9 \$PID"
write_file "$script" "append" "    ifconfig \$PREFIX\$USERS down >/dev/null 2>&1"
write_file "$script" "append" "    ifconfig \$BRIDGE down >/dev/null 2>&1"
write_file "$script" "append" "    ip addr flush \$BRIDGE"
write_file "$script" "append" ""
write_file "$script" "append" "    # remove the interfaces from the bridge"
write_file "$script" "append" "    brctl delif \$BRIDGE \$NIC"
write_file "$script" "append" ""
write_file "$script" "append" "    for interface in \$INTERFACES"
write_file "$script" "append" "    do"
write_file "$script" "append" "       interface_name=\$PREFIX\$interface"
write_file "$script" "append" "       brctl delif \$BRIDGE \${interface_name}"
write_file "$script" "append" "       tapctrl -n \${interface_name} -a delete -o \$user -t tap"
write_file "$script" "append" "    done"
write_file "$script" "append" "    ip link set \$BRIDGE down"
write_file "$script" "append" "    # delete the bridge"
write_file "$script" "append" "    brctl delbr \$BRIDGE"
write_file "$script" "append" ""
write_file "$script" "append" "    # unset promiscous mode"
write_file "$script" "append" "    ifconfig \$NIC \$HOST_IP -promisc up"
write_file "$script" "append" ""
write_file "$script" "append" "    # bring up the network"
write_file "$script" "append" "    route add default gw \$DEFAULT_GW \$NIC"
write_file "$script" "append" "    ifconfig \$NIC down"
write_file "$script" "append" "    sleep 3"
write_file "$script" "append" "    ifconfig \$NIC up"
write_file "$script" "append" "    ip addr show 2>&1 > /var/log/fm_bridge_delete.log"
write_file "$script" "append" "    sleep 3"
write_file "$script" "append" "}"
write_file "$script" "append" "RETVAL=0"
write_file "$script" "append" "case \"\$1\" in"
write_file "$script" "append" "    start)"
write_file "$script" "append" "           start"
write_file "$script" "append" "           ;;"
write_file "$script" "append" "    stop)"
write_file "$script" "append" "           stop"
write_file "$script" "append" "           ;;"
write_file "$script" "append" "    restart)"
write_file "$script" "append" "           stop"
write_file "$script" "append" "           start"
write_file "$script" "append" "           ;;"
write_file "$script" "append" "    *)"
write_file "$script" "append" "           echo -e \"Usage: \$0 {start|stop|restart}\""
write_file "$script" "append" "           RETVAL=1"
write_file "$script" "append" "esac"
write_file "$script" "append" ""
write_file "$script" "append" "exit \$RETVAL"

write_file "$script" "append" "# Script End"
chmod 755 "$script"

print "done."

print ""
print "Info: init script created at '$script'.
You can create symlinks to this script in appropriate locations for your
system's runlevels. For example,
on Red Hat / Fedora you might create links of the form:
  $ sudo chkconfig --level 345 $scriptname on
on Ubuntu / Debian you might create links of the form:
  $ sudo update-rc.d $scriptname defaults"
print ""
print "If you have installed the 'chkconfig' package, then you can
delete network TAP bridge or create it by following commands:
  $ sudo service $scriptname stop
or
  $ sudo service $scriptname start"
print ""


print "Script finished. Thanks for using Fast Models. " 
sleep 3

# End of the script
