#!/bin/sh

mtdstr=$(cat /proc/mtd 2>/dev/null)
cmdstr=$(cat /proc/cmdline |awk '{print $1}')
ubidetach="/tmp/ubidetach"
ubifile=""

if [ ! -f ${ubidetach} ] ; then
	echo "Failed to get ubidetach file"
	exit
else
	chmod +x ${ubidetach}
fi

if echo "$mtdstr" |grep "mtd12: 02c80000 00020000 \"rootfs\"" ; then
	if echo "$mtdstr" |grep "mtd13: 02c80000 00020000 \"rootfs_1\"" ; then
		ubifile="/tmp/ubi-JIKEAP_AX1800MI.img"
	fi
fi

if echo "$mtdstr" |grep "mtd18: 02400000 00020000 \"rootfs\"" ; then
	if echo "$mtdstr" |grep "mtd19: 02400000 00020000 \"rootfs_1\"" ; then
		ubifile="/tmp/ubi-JIKEAP_AX5RM.img"
	fi
fi

if [ "/tmp/ubi-JIKEAP_AX1800MI.img" = "${ubifile}" ] ; then
	if [ ! -f ${ubifile} ] ; then
		echo "ubi image file[${ubifile}] not found"
		exit
	fi

	nvram set uart_en=1
	nvram set boot_wait=on
	nvram set flag_try_sys2_failed=1
	nvram commit

	mtdn="/dev/mtd12"
	if [ "ubi.mtd=rootfs" = "${cmdstr}" ] ; then
		${ubidetach} -f -p ${mtdn}
	fi
	ubiformat ${mtdn} -y -f ${ubifile}
	echo "AX1800 rootfs update ok, please reboot now"

elif [ "/tmp/ubi-JIKEAP_AX5RM.img" = "${ubifile}" ] ; then
	if [ ! -f ${ubifile} ] ; then
		echo "ubi image file[${ubifile}] not found"
		exit
	fi

	nvram set uart_en=1
	nvram set boot_wait=on
	nvram set flag_try_sys2_failed=1
	nvram commit

	mtdn="/dev/mtd18"
	if [ "ubi.mtd=rootfs" = "${cmdstr}" ] ; then
		${ubidetach} -f -p ${mtdn}
	fi
	ubiformat ${mtdn} -y -f ${ubifile}
	echo "AX5 rootfs update ok, please reboot now"

else
	echo "Failed to detect device"
fi
